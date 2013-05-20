use Test::More qw/no_plan/;
use Test::Exception;

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
    lives_ok { $schema = chado_schema() } 'should exports chado_schema';
    isa_ok( $schema, 'DBIx::Class::Schema' );
    lives_ok { reload_schema() } 'should exports reload_schema';
};

subtest 'schema and fixture management with default loader' => sub {
    my $schema;
    lives_ok { $schema = chado_schema( load_fixture => 1 ) }
    'should accept fixture loading option';
    isa_ok( $schema, 'DBIx::Class::Schema' );

    #is( $schema->resultset('Organism::Organism')->count( {} ),
        #12, 'should loaded 12 organisms' );

    #lives_ok { reload_schema() } 'should reloads the schema';
    #is( $schema->resultset('Organism::Organism')->count( {} ),
        #0, 'should not have any organism loaded' );

};
