use Test::More qw/no_plan/;
use Test::Exception;
use Test::Chado::DBManager::Pg;
use Test::DatabaseRow;

use_ok('Test::Chado::FixtureLoader::Preset');
SKIP: {
    skip 'Environment variable TC_DSN is not set',
        if not defined $ENV{TC_DSN};
    eval { require DBD::Pg };
    skip 'DBD::Pg is needed to run this test' if $@;

    subtest 'loading all fixtures from preset' => sub {
        my $dbmanager = Test::Chado::DBManager::Pg->new(
            dsn      => $ENV{TC_DSN},
            user     => $ENV{TC_USER},
            password => $ENV{TC_PASSWORD}
        );

        $dbmanager->drop_schema;
        $dbmanager->deploy_schema;
        local $Test::DatabaseRow::dbh = $dbmanager->dbh;

        my $loader = new_ok('Test::Chado::FixtureLoader::Preset');
        lives_ok { $loader->dbmanager($dbmanager) }
        'should set the dbmanager';
        lives_ok { $loader->load_fixtures }
        'should load fixtures from preset';

        row_ok(
            sql         => "SELECT * FROM organism",
            results     => 12,
            description => 'should have 12 organisms'
        );

        my $sql = <<'SQL';
    SELECT CVTERM.* from CVTERM join CV on CV.CV_ID=CVTERM.CV_ID 
    WHERE CV.NAME = 'sequence';
SQL

        row_ok(
            results     => 286,
            description => 'should have 286 sequence ontology terms',
            sql         => $sql
        );

        $sql = <<'SQL';
    SELECT CVTERM.* from CVTERM join CV on CV.CV_ID=CVTERM.CV_ID 
    WHERE CV.NAME = 'relationship';
SQL
        row_ok(
            results     => 26,
            description => 'should have 26 relation ontology terms',
            sql         => $sql
        );

    };
}
