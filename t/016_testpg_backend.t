use Test::More qw/no_plan/;
use Test::Exception;
use Test::DatabaseRow;
use Module::Load;

SKIP: {
    skip 'Environment variable TC_TESTPG not set',
        if not exists $ENV{TC_TESTPG};
    eval { require Test::PostgreSQL };
    skip 'Test::PostgreSQL is needed to run this test' if $@;

    use_ok('Test::Chado::DBManager::Testpg');
    my $pg = new_ok 'Test::Chado::DBManager::Testpg';

    lives_ok { $pg->dbh } 'should setup a dbh handle';
    local $Test::DatabaseRow::dbh = $pg->dbh;

    subtest 'testpg backend with DBI' => sub {
        lives_ok { $pg->deploy_by_dbi } 'should deploy with dbi';

        my $sql = <<'SQL';
               SELECT reltype FROM pg_class where 
                 relnamespace = (SELECT oid FROM 
                 pg_namespace where nspname = 'public')
                 and relname IN('feature', 'dbxref', 'cvterm')
SQL
        row_ok(
            sql         => $sql,
            results     => 3,
            description => 'should have three existing table'
        );
        lives_ok { $pg->drop_schema } "should drop the schema";
    };

    subtest 'deploy and reset schema with testpg backend' => sub {
        lives_ok { $pg->deploy_schema } 'should deploy';
        lives_ok { $pg->reset_schema } 'should reset the schema';

        my $sql = <<'SQL';
               SELECT reltype FROM pg_class where 
                 relnamespace = (SELECT oid FROM 
                 pg_namespace where nspname = 'public')
                 and relname IN('feature', 'dbxref', 'cvterm', 'cv')
SQL
        row_ok(
            sql         => $sql,
            results     => 4,
            description => 'should have three existing table'
        );
        lives_ok { $pg->drop_schema } "should drop the schema";

    };

    subtest 'loading all fixtures from flatfile' => sub {

        $pg->drop_schema;
        $pg->deploy_schema;

        load 'Test::Chado::FixtureLoader::Flatfile';
        my $loader
            = Test::Chado::FixtureLoader::Flatfile->new( dbmanager => $pg );

        lives_ok { $loader->load_fixtures } 'should load all fixtures';

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
        $pg->drop_schema;
    };

    subtest 'loading all fixtures from preset' => sub {
        $pg->drop_schema;
        $pg->deploy_schema;

        load 'Test::Chado::FixtureLoader::Preset';
        my $loader
            = Test::Chado::FixtureLoader::Preset->new( dbmanager => $pg );

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
        $pg->drop_schema;

    };

    subtest 'schema and fixture managements with testpg' => sub {
        local @ARGV = ('--testpg');

        load Test::Chado, ':default';

        my $schema;
        lives_ok { $schema = chado_schema() } 'should run chado_schema';
        isa_ok( $schema, 'Bio::Chado::Schema' );
        isa_ok( Test::Chado->get_fixture_loader->dbmanager,
            'Test::Chado::DBManager::Testpg' );

        local $Test::DatabaseRow::dbh
            = Test::Chado->get_fixture_loader->dbmanager->dbh;

        my $sql = <<'SQL';
               SELECT reltype FROM pg_class where 
                 relnamespace = (SELECT oid FROM 
                 pg_namespace where nspname = 'public')
                 and relname IN('feature', 'dbxref', 'cvterm')
SQL
        row_ok(
            sql         => $sql,
            results     => 3,
            description => 'should have three existing table'
        );

        lives_ok { drop_schema() } 'should run drop_schema';
        row_ok(
            sql         => $sql,
            results     => 0,
            description => 'should not have three existing table'
        );

        lives_ok { $schema = chado_schema( load_fixture => 1 ) }
        'should accept fixture loading option';
        isa_ok( $schema, 'Bio::Chado::Schema' );

        is( $schema->resultset('Organism::Organism')->count( {} ),
            12, 'should loaded 12 organisms' );

        lives_ok { reload_schema() } 'should reloads the schema';

        local $Test::DatabaseRow::dbh
            = Test::Chado->get_fixture_loader->dbmanager->dbh;

        my $sql = <<'SQL';
               SELECT reltype FROM pg_class where 
                 relnamespace = (SELECT oid FROM 
                 pg_namespace where nspname = 'public')
                 and relname IN('feature')
SQL
        row_ok(
            sql         => $sql,
            results     => 1,
            description => 'should have feature table after loading'
        );
        is( $schema->resultset('Organism::Organism')->count( {} ),
            0, 'should not have any fixture after reload' );

    };
}
