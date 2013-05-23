package Test::Chado::DBManager::Pg;

use namespace::autoclean;
use Moo;
use MooX::late;
use Types::Standard qw/Bool/;
use DBI;
use IPC::Cmd qw/can_run run/;

has 'is_dynamic_schema' => ( is => 'ro', isa => Bool, default => 0 );
with 'Test::Chado::Role::HasDBManager';

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
    my $dbh    = $self->dbh;
    my $tsth   = $dbh->prepare(
        "SELECT relname FROM pg_class WHERE relnamespace IN
          (SELECT oid FROM pg_namespace WHERE nspname='public')
          AND relkind='r';"
    );

    my $vsth = $dbh->prepare(
        "SELECT viewname FROM pg_views WHERE schemaname NOT IN ('pg_catalog',
			 'information_schema') AND viewname !~ '^pg_'"
    );

    my $seqth = $dbh->prepare(
        "SELECT relname FROM pg_class WHERE relkind = 'S' AND relnamespace IN ( SELECT oid FROM
	 pg_namespace WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema')"
    );

    $tsth->execute;
    while ( my ($table) = $tsth->fetchrow_array ) {
        $dbh->do(qq{ drop table $table cascade });
    }

    my $seqs = join( ",",
        map { $_->{relname} }
            @{ $dbh->selectall_arrayref( $seqth, { Slice => {} } ) } );

    if ($seqs) {
        $dbh->do(qq{ drop sequence if exists $seqs });
    }

    my $views = join( ",",
        map { $_->{viewname} }
            @{ $dbh->selectall_arrayref( $vsth, { Slice => {} } ) } );

    if ($views) {
        $dbh->do(qq{ drop view if exists $views });
    }
}

sub get_client_to_deploy {
    my ($self) = @_;
    if (my $cmd = can_run 'psql' ) {
        return $cmd;
    }
}

sub deploy_by_client {
    my ( $self, $client ) = @_;
    my $host = 'localhost';
    if ( $self->dsn =~ /host=(\S+)/ ) { $host = $1; }
    my $user = $self->user || '';
    my $pass = $self->pass || '';
    my $cmd  = [
        $client, '-h', $host, '-u', $user, '-p', $pass, '-f', $self->ddl,
        $self->database
    ];
    my ( $success, $error_code, $full_buf,, $stdout_buf, $stderr_buf )
        = run( command => $cmd, verbose => 1 );
    return $success if $success;
    die "unable to run command : ", $error_code, " ", $stderr_buf;
}

1;
