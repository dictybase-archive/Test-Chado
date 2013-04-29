package Test::Chado::Types;

use Type::Library
    -base,
    -declare => qw(DBH DbManager BCS);
use Type::Utils;
use Types::Standard -types;

class_type DBH, { class => "DBI::db"};
class_type BCS, { class => "Bio::Chado::Schema"};
role_type DbManager, { role => 'Test::Chado::Role::HasDBManager'};

1;
