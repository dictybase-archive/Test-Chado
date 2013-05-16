package Test::Chado;
use Test::Chado::Factory::DBManager;
use Test::Chado::Factory::FixtureLoader;
use Test::Chado::Types qw/FixtureLoader/;
use Moo;
use DBI;
use MooX::ClassAttribute;
use MooX::late;
use Getopt::Long;
use Sub::Exporter::Util qw/curry_method/;
use Sub::Exporter -setup => {
    exports => {
        'chado_schema'       => curry_method,
        'drop_schema'        => curry_method,
        'reload_schema'      => curry_method,
        'set_fixture_loader' => curry_method
    },
    groups => {
        'default' => [qw/chado_schema reload_schema set_fixture_loader/],
        'schema'  => [qw/chado_schema drop_schema reload_schema/]
    }
};

my $opt = {};
GetOptions( $opt, 'dsn:s', 'user:s', 'password:s' );

class_has '_fixture_loader_instance' => (
    is  => 'rw',
    isa => FixtureLoader,
);

class_has '_fixture_loader' =>
    ( is => 'rw', isa => Str, default => 'preset', lazy => 1 );

sub set_fixture_loader {
    my ( $class, $arg ) = @_;
    if ($arg) {
        $class->_fixture_loader($arg);
    }
}

sub reload_schema {
    my $class          = shift;
    my $fixture_loader = $class->get_fixture_loader;
    $fixture_loader->dbmanager->reset_schema;
}

sub drop_schema {
    my $class          = shift;
    my $fixture_loader = $class->get_fixture_loader;
    $fixture_loader->dbmanager->drop_schema;
}

sub chado_schema {
    my ( $class, %arg ) = @_;
    my $fixture_loader = $class->get_fixture_loader;
    $fixture_loader->load_fixture
        if defined $arg{'load-fixture'};
    return $fixture_loader->schema;
}

sub get_fixture_loader {
    my ($class) = shift;
    if ( !$class->_fixture_loader_instance ) {
        my ( $loader, $dbmanager );
        if ( defined $opt{dsn} ) {
            my ( $scheme, $driver, $attr_str, $attr_hash, $driver_dsn )
                = DBI->parse_dsn( $opt{dsn} );
            $dbmanager
                = Test::Chado::Factory::DBManager->get_instance($driver);
            $dbmanager->dsn( $opt{dsn} );
            $dbmanager->user( $opt{user} )         if defined $opt{user};
            $dbmanager->password( $opt{password} ) if defined $opt{password};
        }
        else {
            $dbmanager
                = Test::Chado::Factory::DBManager->get_instance('sqlite');
        }

        $loader = Test::Chado::Factory::FixtureLoader->get_instance(
            $class->_fixture_loader );
        $loader->dbmanager($dbmanager);
        $class->_fixture_loader_instance($loader);
    }
    return $class->_fixture_loader_instance;
}

1;

# ABSTRACT: Build,configure and test chado database backed modules and applications

=head1 Build Status

=begin HTML

<a href='https://travis-ci.org/dictyBase/Test-Chado'>
  <img src='https://travis-ci.org/dictyBase/Test-Chado.png?branch=develop'
  alt='Travis CI status'/></a>

<a href='https://coveralls.io/r/dictyBase/Test-Chado'><img
src='https://coveralls.io/repos/dictyBase/Test-Chado/badge.png?branch=develop'
alt='Coverage Status' /></a>


=end HTML

=head1 SYNOPSIS

=head3 Write build script(Build.PL) for your module or web application:

   use Module::Build::Chado;

   my $build = Module::Build::Chado->new(
                 module_name => 'MyChadoApp', 
                 license => 'perl', 
                 dist_abstract => 'My chado module'
                 dist_version => '1.0'

   );

  $build->create_build_script;


=head3 Then from the command line:

  perl Build.PL && ./Build test(default is a temporary SQLite database)

It will deploy chado schema in a SQLite database, load fixtures and run all tests)


=head3 In each of the test file(.t) access the schema(Bio::Chado::Schema) object

   use Module::Build::Chado;

   my $schema = Module::Build::Chado->current->schema;

   #do something with it ....

   $schema->resultset('Organism::Organism')->....

=head3 Use for other database backend

B<PostgreSQL>

  ./Build test --dsn "dbi:Pg:dbname=mychado" --user tucker --password booze

B<Oracle>

   ./Build test --dsn "dbi:Oracle:sid=myoracle" --user tucker --password hammer


=head1 DESCRIPTION

This is subclass of L<Module::Build> to configure,  build and test
L<chado|http://gmod.org/wiki/Chado> database backed
perl modules and applications. During the B</Build test>  testing phase it loads some
default fixtures which can be accessed in every test(.t) file using standard
L<DBIx::Class> API.

=head2 Default fixtures loaded

=over

=item  List of organisms

Look at the organism.yaml in the shared folder

=item Relationship ontology

OBO relationship types, available here
L<http://bioportal.bioontology.org/ontologies/1042>. 

=item Sequence ontology

Sequence types and features,  available here
L<http://bioportal.bioontology.org/ontologies/1109>

=back


=head2 Accessing fixtures data in test(.t) files

=over

=item Get a L<Bio::Chado::Schema> aka L<DBIx::Class> object

my $schema = Module::Build->current->schema;

isa_ok($schema, 'Bio::Chado::Schema');

=item Access them using L<DBIx::Class> API

  my $row = $schema->resultset('Organism::Organism')->find({species => 'Homo',  genus =>
'sapiens'});

  my $resultset = $schema->resultset('Organism::Organism')->search({});

  my $relonto = $schema->resultset('Cv::Cv')->find({'name' => 'relationship'});

  my $seqonto = $schema->resultset('Cv::Cv')->find({'name' => 'sequence'});

  my $cvterm_rs = $seqonto->cvterms;
  
  while(my $cvterm = $cvterm_rs->next) {
    .....
  }

  You probably will not be accessing them too often,  but mostly needed to load other test
  fixtures.

=back

=head2 Loading custom fixtures

=over 

=item *

Create your own subclass and implement either or both of two methods
B<before_all_fixtures> and B<after_all_fixtures>

=over

=item before_all_fixtures

This code will run before any fixture is loaded

=item after_all_fixtures

This code will run after organism data, relationship and sequence ontologies are loaded

=back

   package MyBuilder;
   use base qw/Module::Build::Chado/;

   sub before_all_fixtures {
      my ($self) = @_;
   }

   sub before_all_fixtures {
      my ($self) = @_;
   }

=item *

All the attributes and methods of B<Module::Build> and B<Module::Build::Chado> L<API>
become available through I<$self>.
 
=back


=head1 API

=attr schema

A L<Bio::Chado::Schema> object.

=attr dsn

Database connect string,  defaults to a temporary SQLite database.

=attr user

Database user,  not needed for SQLite backend.

=attr password

Database password,  not needed for SQLite backend.

=attr superuser

Database super user, in case the regular use do not have enough permissions for
manipulating the database schema. It defaults to the user attribute.

=attr superpassword

Similar concept as superuser

=attr ddl

DDL file for particular backend,  by default comes for SQLite,  Postgresql and Oracle.

=attr organism_fixuture

Fixture for loading organisms,  by default the distribution comes with a organism.yaml
file.

=attr rel_fixuture

Relation ontology file in obo_xml format. The distribution includes a relationship.obo_xml
file.

=attr so_fixuture

Sequence ontology file in obo_xml format. By default,  it includes sofa.obo_xml file.



=method connect_hash

Returns a hash with the following connection specific keys ...

=over

=item dsn

=item user

=item password

=item dbi_attributes

=back

=method connect_info

Returns an 4 elements array with connection arguments identical to L<DBI>'s B<connect>
method.

