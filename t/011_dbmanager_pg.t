use Test::More qw/no_plan/;
use Test::Exception;
use IPC::Cmd qw/can_run/;
use Test::DatabaseRow;

use_ok('Test::Chado::DBManager::Pg');
my $pg = new_ok 'Test::Chado::DBManager::Pg';

SKIP: {
    skip 'Environment variable TC_DSN is not set',
        if not defined $ENV{TC_DSN};
    eval { require DBD::Pg };
    skip 'DBD::Pg is needed to run this test' if $@;

    $pg->dsn( $ENV{TC_DSN} );
    $pg->user( $ENV{TC_USER} );
    $pg->password( $ENV{TC_PASSWORD} );
    local $Test::DatabaseRow::dbh = $pg->dbh;

    subtest 'custom pg backend with DBI' => sub {

        lives_ok { $pg->deploy_by_dbi } 'should deploy with dbi';
        $sql = <<'SQL';
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

    subtest 'deploy and reset schema with Pg backend' => sub {
        lives_ok { $pg->deploy_schema } 'should deploy';
        lives_ok { $pg->reset_schema } 'should reset the schema';

        $sql = <<'SQL';
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
}
