package Test::Chado::Types;

use Type::Library
    -base,
    -declare => qw(DBH DbManager);
use Type::Utils;
use Types::Standard -types;

class_type DBH, { class => "DBI::db"};
role_type DbManager, { role => 'Test::Chado::Role::HasDBManager'};

1;
