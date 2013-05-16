package Test::Chado::FixtureManager::Flatfile;
use File::ShareDir qw/module_dir/;
use Moo;
use MooX::late;
use Types::Standard qw/Str/;
use Carp;
use File::Spec::Functions;
use Test::Chado;

has 'default_fixture_path' => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => sub { return catfile( module_dir('Test::Chado') ) }
);

has 'fixture_path' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->default_fixture_path;
    }
);

has 'organism_fixture' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    default => sub {
        my $self = shift;
        return catfile( $self->default_fixture_path, 'organism.yaml' );
    }
);

has 'rel_fixture' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    default => sub {
        my $self = shift;
        return catfile( $self->default_fixture_path, 'relationship.obo_xml' );
    }
);

has 'so_fixture' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    default => sub {
        my $self = shift;
        return catfile( $self->default_fixture_path, 'sofa.obo_xml' );
    }
);
1;
