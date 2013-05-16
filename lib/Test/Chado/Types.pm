package Test::Chado::Types;

use Type::Library
    -base,
    -declare =>
    qw(DBH DbManager BCS Twig Graph GraphT HashiFied FixtureManager FixtureLoader DBIC);
use Type::Utils;

class_type DBH,    { class => "DBI::db" };
class_type DBIC,   { class => "DBIx::Class::Schema" };
class_type Twig,   { class => "XML::Twig" };
class_type Graph,  { class => "Graph" };
class_type GraphT, { class => "Graph::Traversal" };
class_type BCS,    { class => "Bio::Chado::Schema" };
class_type FixtureManager,
    { class => "Test::Chado::FixtureManager::Flatfile" };
class_type HashiFied,    { class => "Data::Perl::Collection::Hash" };
role_type DbManager,     { role  => 'Test::Chado::Role::HasDBManager' };
role_type FixtureLoader, { role  => 'Test::Chado::Role::Helper::WithBcs' }

    1;
