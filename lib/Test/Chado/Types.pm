package Test::Chado::Types;

use Type::Library
    -base,
    -declare => qw(DBH);
use Type::Utils;

class_type DBH, { class => "DBI::db"};
