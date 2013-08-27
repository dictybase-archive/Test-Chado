package Test::Chado::DBManager::Testpg;

use namespace::autoclean;
use Moo;
use DBI;
use Test::PostgreSQL;
extends qw/Test::Chado::DBManager::Pg/;

sub _build_dbh {
    my ($self) = @_;
    my $pg = Test::PostgreSQL->new or die $Test::PostgreSQL::errstr;
    $self->dsn( $pg->dsn );
    my $dbh = DBI->connect( $self->dsn, $self->user, $self->password,
        $self->dbi_attributes );
    $dbh->do(qq{SET client_min_messages=WARNING});
    return $dbh;
}

1;
