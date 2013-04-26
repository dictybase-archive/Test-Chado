use Test::More qw/no_plan/;
use IPC::Cmd qw/can_run/;
use Test::Exception;

use_ok('Test::Chado::DBManager::Sqlite');
my $sqlite = new_ok('Test::Chado::DBManager::Sqlite');

like( $sqlite->dsn, qr/dbi:SQLite:dbname=\S+/, 'should match a Sqlite dsn' );
like( $sqlite->database, qr/^\S+$/, 'should match the database name' );
like($sqlite->ddl,qr/chado.sqlite$/, 'should have a sqlite ddl file');

isa_ok( $sqlite->dbh, 'DBI::db' );
SKIP: {
    my $client = can_run('sqlite3');
    skip 'sqlite client is not installed', if !$client;

    lives_ok { $sqlite->get_client_to_deploy }
    'should have a command line client';
    lives_ok { $sqlite->deploy_by_client($client) }
    'should deploy with command line client';

    my @row = $sqlite->dbh->selectrow_array(
        "SELECT name FROM sqlite_master where
	type = ? and tbl_name = ?", {}, qw/table feature/
    );

    ok( @row, "should have feature table present in the database" );

    lives_ok { $sqlite->drop_schema } "should drop the schema";

    my @row2 = $sqlite->dbh->selectrow_array(
        "SELECT name FROM sqlite_master where
	type = ? and tbl_name = ?", {}, qw/table feature/
    );

    isnt( @row2, 1, "should not have feature table in the database" );
}

my $sqlite2 = new_ok('Test::Chado::DBManager::Sqlite');
lives_ok { $sqlite2->deploy_by_dbi } 'should deploy without client';

my @row2 = $sqlite2->dbh->selectrow_array(
    "SELECT name FROM sqlite_master where
	type = ? and tbl_name = ?", {}, qw/table cvterm/
);

ok( @row2, "should have cvterm table present in the database" );
lives_ok { $sqlite2->drop_database } 'should disconnect';
