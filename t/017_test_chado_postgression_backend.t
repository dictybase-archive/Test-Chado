use Test::More qw/no_plan/;
use Test::Exception;
use Test::DatabaseRow;
use Module::Load;

SKIP: {
    skip 'Environment variable TC_POSTGRESSION not set',
        if not exists $ENV{TC_POSTGRESSION};
    eval { require DBD::Pg };
    skip 'DBD::Pg is needed to run this test' if $@;

    subtest 'schema and fixture managements with postgression' => sub {

        local @ARGV = ("--postgression");
        load Test::Chado, ':default';

        my $schema;
        lives_ok { $schema = chado_schema() } 'should run chado_schema';
        isa_ok( $schema, 'Bio::Chado::Schema' );
        isa_ok(
            Test::Chado->get_fixture_loader->dbmanager,
            'Test::Chado::DBManager::Postgression'
        );

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

        $sql = <<'SQL';
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
