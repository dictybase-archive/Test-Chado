package TestBcsHelper;

use Moo;
use MooX::late;
use Test::Chado::Types qw/BCS/;
use Types::Standard qw/Str/;

has 'namespace' => ( is => 'rw', isa => Str );
has 'schema'    => ( is => 'rw', isa => BCS );
with 'Test::Chado::Role::Helper::WithBcs';

1;

package main;
use Test::More qw/no_plan/;
use Test::Exception;
use Bio::Chado::Schema;
use Test::TypeTiny;
use Test::Chado::DBManager::Sqlite;
use Test::Chado::Types qw/HashiFied/;

subtest 'class with BCS helper role' => sub {
    my $schema
        = Bio::Chado::Schema->connect( "dbi:SQLite:dbname=:memory:", "", "" );

    my $helper = new_ok('TestBcsHelper');
    lives_ok { $helper->schema($schema) } 'should set the schema';
    lives_ok { $helper->namespace('test-bcs-helper') }
    'should set the namespace';
    can_ok( $helper, qw(dbrow cvrow cvterm_row) );
};

subtest 'dbrow attribute in BCS helper role' => sub {
    my $dbmanager = Test::Chado::DBManager::Sqlite->new();
    $dbmanager->deploy_schema;
    my $schema
        = Bio::Chado::Schema->connect( sub { return $dbmanager->dbh } );

    my $helper = TestBcsHelper->new(
        schema    => $schema,
        namespace => 'test-bcs-helper'
    );
    should_pass( $helper->dbrow, HashiFied, 'should return hashref' );
    is( $helper->exist_dbrow('default'), 1, 'should have default dbrow' );
    isa_ok( $helper->get_dbrow('default'), 'DBIx::Class::Row' );
    is( $helper->get_dbrow('default')->name,
        'test-bcs-helper-db', 'should match the default db name' );

    my $new_dbrow = $schema->resultset('General::Db')
        ->find_or_create( { 'name' => 'testtemprow' } );
    lives_ok { $helper->set_dbrow( 'tmp', $new_dbrow ) }
    'should create new dbrow';
    is( $helper->exist_dbrow('tmp'), 1, 'should have the created dbrow' );

};

subtest 'db table in BCS helper role' => sub {
    my $dbmanager = Test::Chado::DBManager::Sqlite->new();
    $dbmanager->deploy_schema;
    my $schema
        = Bio::Chado::Schema->connect( sub { return $dbmanager->dbh } );

    my $helper = TestBcsHelper->new(
        schema    => $schema,
        namespace => 'test-bcs-helper'
    );

    should_pass( $helper->dbrow, HashiFied, 'should return hashref' );
    like( $helper->default_db_id, qr/^\d+$/,
        'should return the default db id' );
    is( $helper->default_db_id,
        $helper->find_db_id('default'),
        'should find the default db id'
    );

    my $new_dbrow = $schema->resultset('General::Db')
        ->find_or_create( { 'name' => 'testtemprow' } );
    isnt( $helper->find_db_id( $new_dbrow->name ),
        1, 'should not find the db id' );

    is( $helper->get_dbrow('default')->db_id,
        $helper->find_or_create_db_id('default'),
        'should find db id from cache'
    );
    is( $new_dbrow->db_id,
        $helper->find_or_create_db_id( $new_dbrow->name ),
        'should find db id from database'
    );
    is( $helper->exist_dbrow( $new_dbrow->name ),
        1, 'should have cached the db id' );
    lives_ok { $helper->find_or_create_db_id('fresh') }
    'should create a new db id';
    is( $helper->exist_dbrow('fresh'), 1,
        'should have cached the new db id' );

};

subtest 'cvrow attribute in BCS helper role' => sub {
    my $dbmanager = Test::Chado::DBManager::Sqlite->new();
    $dbmanager->deploy_schema;
    my $schema
        = Bio::Chado::Schema->connect( sub { return $dbmanager->dbh } );
    my $new_cvrow = $schema->resultset('Cv::Cv')
        ->find_or_create( { 'name' => 'testtemprow' } );
    my $helper = TestBcsHelper->new(
        schema    => $schema,
        namespace => 'test-bcs-helper'
    );
    should_pass( $helper->cvrow, HashiFied, 'should return hashref' );
    is( $helper->exist_cvrow('default'), 1, 'should have default cvrow' );
    isa_ok( $helper->get_cvrow('default'), 'DBIx::Class::Row' );
    is( $helper->get_cvrow('default')->name,
        'test-bcs-helper-cv', 'should match the default db name' );

    lives_ok { $helper->set_cvrow( 'tmp', $new_cvrow ) }
    'should create new cvrow';
    is( $helper->exist_cvrow('tmp'), 1, 'should have the created cvrow' );

};
