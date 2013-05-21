use Test::More qw/no_plan/;
use Test::Exception;
use File::Temp qw/tmpnam/;
use Module::Load qw/load/;
use Class::Unload;

use_ok 'Test::Chado';

subtest 'schema management with default loader' => sub {
    my $loader;
    lives_ok { $loader = Test::Chado->get_fixture_loader }
    'should get default fixture loader';
    isa_ok( $loader, 'Test::Chado::FixtureLoader::Preset' );
    isa_ok(
        Test::Chado->fixture_loader_instance,
        'Test::Chado::FixtureLoader::Preset'
    );
    my $schema;
    lives_ok { $schema = chado_schema() } 'should run chado_schema';
    isa_ok( $schema, 'DBIx::Class::Schema' );

    my @row = $loader->dbmanager->dbh->selectrow_array(
        "SELECT name FROM sqlite_master where
	type = ? and tbl_name = ?", {}, qw/table feature/
    );
    ok( @row, "should have feature table after getting the schema instance" );

    lives_ok { drop_schema() } 'should run drop_schema';
    my @row2 = $loader->dbmanager->dbh->selectrow_array(
        "SELECT name FROM sqlite_master where
	type = ? and tbl_name = ?", {}, qw/table feature/
    );
    isnt( @row2, 1,
        "should not have feature table after dropping the schema" );
};

subtest 'schema and fixture managements with default loader' => sub {
    my $schema;
    lives_ok { $schema = chado_schema( load_fixture => 1 ) }
    'should accept fixture loading option';
    isa_ok( $schema, 'DBIx::Class::Schema' );

    is( $schema->resultset('Organism')->count( {} ),
        12, 'should loaded 12 organisms' );

    lives_ok { reload_schema() } 'should reloads the schema';
    my @row
        = Test::Chado->fixture_loader_instance->dbmanager->dbh
        ->selectrow_array(
        "SELECT name FROM sqlite_master where
	type = ? and tbl_name = ?", {}, qw/table feature/
        );
    ok( @row, 'should have feature table after reloading' );
    is( $schema->resultset('Organism')->count( {} ),
        0, 'should not have any fixture after reload' );

};

subtest 'schema and fixture managements through commandline arguments' =>
    sub {
    my $tmp = tmpnam();
    my $dsn = "dbi:SQLite:dbname=$tmp";
    local @ARGV = ( "--dsn", $dsn );

    Class::Unload->unload('Test::Chado');
    load 'Test::Chado';

    lives_ok { Test::Chado->fixture_loader_instance(undef) }
    'should wipe the fixture loader instance';
    lives_ok { Test::Chado->is_schema_loaded(0) }
    'should reset schema loading flag';


    my $schema;
    lives_ok { $schema = chado_schema( load_fixture => 1 ) }
    'should run chado_schema with load_fixture';
    isa_ok( $schema, 'DBIx::Class::Schema' );
    isa_ok(
        Test::Chado->fixture_loader_instance,
        'Test::Chado::FixtureLoader::Preset'
    );
    is( Test::Chado->fixture_loader_instance->dbmanager->dsn,
        $dsn, 'should match the dsn' );

    lives_ok { drop_schema() } 'should run drop_schema';
    lives_ok { reload_schema() } 'should run reload_schema';
    };
