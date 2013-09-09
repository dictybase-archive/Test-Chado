package ManageEnv;

use Moo;
use MooX::HandlesVia;
use Data::Perl qw/hash/;

has 'tc_env' => (
    is          => 'rw',
    isa         => 'Data::Perl::Collection::Hash',
    handles_via => 'Data::Perl',
    lazy        => 1,
    clearer     => 1,
    default     => sub { return hash( () ); },
    handles     => {
        add_tc_env => 'set',
        get_tc_env => 'get'
    }
);

has 'tc_env_keys' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub {
        return [qw/TC_DSN TC_PASS TC_USER TC_POSTGRESSION TC_TESTPG/];
    }
);

sub preserve_tc_env {
    my ($self) = @_;
    for my $key ( @{ $self->tc_env_keys } ) {
        if ( exists $ENV{$key} ) {
            my $value = defined $ENV{$key} ? $ENV{$key} : 1;
            $self->add_tc_env( $key, $value );
        }
    }
}

sub temp_clean_tc_env {
    my ($self) = @_;
    $self->preserve_tc_env;
    for my $key ( @{ $self->tc_env_keys } ) {
        delete $ENV{$key};
    }
}

sub restore_tc_env {
    my ($self) = @_;
    for my $key ( @{ $self->tc_env_keys } ) {
        $ENV{$key} = $self->get_tc_env($key);
    }
}

1;
