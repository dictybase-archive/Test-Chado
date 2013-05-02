use Test::More qw/no_plan/;
use Test::Exception;
use Test::Chado::DBManager::Sqlite;
use File::ShareDir qw/module_dir/;
use File::Spec::Functions;


use_ok('Test::Chado::FixtureLoader::FlatFile');
subtest 'attributes in flatfile fixtureloader' => sub {
    my $dbmanager = Test::Chado::DBManager::Sqlite->new();

    my $loader = new_ok('Test::Chado::FixtureLoader::FlatFile');
    lives_ok { $loader->dbmanager($dbmanager) } 'should set the dbmanager';
    is( $loader->namespace, 'test-chado', 'should have a default namespace' );
    isa_ok( $loader->fixture_manager,
        'Test::Chado::FixtureManager::FlatFile' );
    isa_ok( $loader->obo_xml_loader, 'XML::Twig' );
    isa_ok( $loader->graph,          'Graph' );
    isa_ok( $loader->traverse_graph, 'Graph::Traversal::BFS' );

    lives_ok {
        $loader->obo_xml(
            catfile( module_dir('Test::Chado'), 'sofa.obo_xml' ) );
    }
    'should set obo_xml attribute';
    is( $loader->ontology_namespace,
        'sequence', 'should have parsed ontology namespace' );
};
