use Test::More qw/no_plan/;
use Test::Exception;

use_ok('Test::Chado::DBManager::Pg');
my $pg = new_ok 'Test::Chado::DBManager::Pg';
