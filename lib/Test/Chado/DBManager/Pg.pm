package Test::Chado::DBManager::Pg;

use namespace::autoclean;
use Moo;
use MooX::late;
use Types::Standard qw/Bool Str/;
use DBI;
use IPC::Cmd qw/can_run run/;
use Data::Random qw/rand_chars/;

has 'is_dynamic_schema' => ( is => 'ro', isa => Bool, default => 0 );
with 'Test::Chado::Role::HasDBManager';

before [ 'deploy_schema', 'deploy_by_dbi' ] => sub {
    my ($self) = shift;
    my $namespace = $self->schema_namespace;
    $self->dbh->do(qq{CREATE SCHEMA $namespace});
    $self->dbh->do(qq{SET search_path TO $namespace});
};

has 'schema_namespace' => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return join '',
            rand_chars( set => 'alpha', min => 9, max => 10 );
    }
);

sub _build_dbh {
    my ($self) = @_;
    my $dbh = DBI->connect( $self->dsn, $self->user, $self->password,
        $self->dbi_attributes );
    $dbh->do(qq{SET client_min_messages=WARNING});
    return $dbh;
}

sub _build_database {
    my ($self) = @_;
    my $driver_dsn;
    if ( $self->driver_dsn ) {
        $driver_dsn = $self->driver_dsn;
    }
    else {
        my @parsed_dsn = DBI->parse_dsn( $self->dsn );
        $driver_dsn = $parsed_dsn[-1];
    }
    if ( $driver_dsn =~ /d(atabase|b|bname)=(\w+)\;/ ) {
        return $2;
    }
}

sub _build_driver { return 'Pg' }

sub create_database {
    return 1;
}

sub drop_database {
    my ($self) = @_;
    return 1;
}

sub drop_schema {
    my ($self) = @_;
    my $namespace = $self->schema_namespace;
    $self->dbh->do(qq{DROP SCHEMA $namespace CASCADE});
}

sub get_client_to_deploy {
    return;
}

sub deploy_by_client {
    my ( $self, $client ) = @_;
    my $host = 'localhost';
    if ( $self->dsn =~ /host=([^;]+)/ ) { $host = $1; }
    my $user = $self->user || '';
    $ENV{PGPASSWORD} = $self->password || '';
    my $cmd = [
        $client, '-h', $host,      '-U',
        $user,   '-f', $self->ddl, $self->database
    ];
    my ( $success, $error_code, $full_buf,, $stdout_buf, $stderr_buf )
        = run( command => $cmd, verbose => 1 );
    return $success if $success;
    die "unable to run command : ", $error_code, " ", $stderr_buf;
}

1;
