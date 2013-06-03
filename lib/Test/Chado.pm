package Test::Chado;
use Test::Chado::Factory::DBManager;
use Test::Chado::Factory::FixtureLoader;
use Test::Chado::Types qw/MaybeFixtureLoader MaybeDbManager/;
use Types::Standard qw/Str Bool/;
use Moo;
use DBI;
use MooX::ClassAttribute;
use Getopt::Long;
use Sub::Exporter -setup => {
    exports => {
        'chado_schema'       => \&_build_schema,
        'drop_schema'        => \&_drop_schema,
        'reload_schema'      => \&_reload_schema,
        'set_fixture_loader' => \&_set_fixture_loader
    },
    groups => {
        'default' =>
            [qw/chado_schema reload_schema set_fixture_loader drop_schema/],
        'schema' => [qw/chado_schema drop_schema reload_schema/]
    }
};

my %opt = ();
GetOptions( \%opt, 'dsn:s', 'user:s', 'password:s' , 'postgression', 'testpg');

class_has 'dbmanager_instance' => ( is => 'rw', isa => MaybeDbManager );

class_has 'is_schema_loaded' =>
    ( is => 'rw', isa => Bool, default => 0, lazy => 1 );

class_has 'fixture_loader_instance' => (
    is  => 'rw',
    isa => MaybeFixtureLoader,
);

class_has 'fixture_loader' =>
    ( is => 'rw', isa => Str, default => 'preset', lazy => 1 );

sub _set_fixture_loader {
    my ($class) = @_;
    return sub {
        my ($arg) = @_;
        if ($arg) {
            $class->fixture_loader($arg);
        }
    };
}

sub _reload_schema {
    my ($class) = @_;
    return sub {
        my $fixture_loader = $class->get_fixture_loader;
        $fixture_loader->dbmanager->reset_schema;
        $class->is_schema_loaded(1);
    };
}

sub _drop_schema {
    my ($class) = @_;
    return sub {
        my $fixture_loader = $class->get_fixture_loader;
        $fixture_loader->dbmanager->drop_schema;
        $class->is_schema_loaded(0);
    };
}

sub _build_schema {
    my ($class) = @_;
    return sub {
        my (%arg) = @_;
        my $fixture_loader = $class->get_fixture_loader;
        if ( !$class->is_schema_loaded ) {
            $fixture_loader->dbmanager->deploy_schema;
            $class->is_schema_loaded(1);
        }
        $fixture_loader->load_fixtures
            if defined $arg{'load_fixture'};
        return $fixture_loader->dynamic_schema;
    };
}

sub get_fixture_loader {
    my ($class) = @_;
    if ( !$class->fixture_loader_instance ) {
        my ( $loader, $dbmanager );
        if (exists $opt{postgression}) {
            $dbmanager
                = Test::Chado::Factory::DBManager->get_instance('postgression');
        }
        elsif (exists $opt{testpg}) {
            $dbmanager
                = Test::Chado::Factory::DBManager->get_instance('testpg');
        }
        elsif ( defined $opt{dsn} ) {
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
                = $class->dbmanager_instance
                ? $class->dbmanager_instance
                : Test::Chado::Factory::DBManager->get_instance('sqlite');
        }

        $loader = Test::Chado::Factory::FixtureLoader->get_instance(
            $class->fixture_loader );
        $loader->dbmanager($dbmanager);
        $class->fixture_loader_instance($loader);
    }
    return $class->fixture_loader_instance;
}


1;

# ABSTRACT: Unit testing for chado database modules and applications

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


=head1 DESCRIPTION


=head1 API

=head2 Attributes

=over

=item dbmanager_instance

Instance of a backend manager that implements L<Test::Chado::Role::HasDBManager> role, currently either of Sqlite or Pg backend will be available.

=item is_schema_loaded

Flag to check the loading status of chado schema

=item fixture_loader_instance 

Insatnce of L<Test::Chado::FixtureLoader::Preset> by default.

=item fixture_loader

Type of fixture loader, could be either of B<preset> and flatfile. By default it is B<preset>

=back

=head2 Methods

All the methods are available as exported subroutines by default

=over

=item chado_schema(%options)

Return an instance of DBIx::Class::Schema for chado database.

However, because of the way the backends works, for Sqlite it returns a on the fly schema generated from L<DBIx::Class::Schema::Loader>, whereas for B<Pg> backend it returns L<Bio::Chado::Schema>

=over

=item options

B<load_fixture> : Pass a true value(1) to load the default fixture

=back

=back

=over

=item drop_schema

=item reload_schema

Drops and then reloads the schema.

=item set_fixture_loader

Sets the type of fixture loader backend it should use, either of B<preset> or B<flatfile>.

=back


