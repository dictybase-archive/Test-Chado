package Test::Chado::Types;

use Type::Library
    -base,
    -declare => qw(DBH DbManager BCS HashiFied);
use Type::Utils;

class_type DBH, { class => "DBI::db"};
class_type BCS, { class => "Bio::Chado::Schema"};
class_type HashiFied, { class => "Data::Perl::Collection::Hash"};
role_type DbManager, { role => 'Test::Chado::Role::HasDBManager'};

1;
