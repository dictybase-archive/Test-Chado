package Test::Chado::DBManager::Postgression;

use namespace::autoclean;
use Moo;
use DBI;
use HTTP::Tiny;
use JSON;
use feature qw/say/;
extends qw/Test::Chado::DBManager::Pg/;

sub _build_dbh {
    my ($self) = @_;
    my $ua = HTTP::Tiny->new(
        default_headers => { 'Accept' => 'application/json' } );
    my $response = $ua->get('http://api.postgression.com');

    if (!$response->{success}) {
        say "request to postgression failed !!!!";
        die "status: $response->{status}\treason: $response->{reason}\n";
    }

    my $resp_hash = decode_json $response->{content};
    my $dsn
        = "dbi:Pg:dbname=$resp_hash->{dbname};host=$resp_hash->{host};port=$resp_hash->{port}";
    $self->dsn($dsn);
    $self->user( $resp_hash->{username} );
    $self->password( $resp_hash->{password} );

    my $attr = $self->dbi_attributes;
    $attr->{AutoCommit} = 1;
    my $dbh = DBI->connect( $self->dsn, $self->user, $self->password, $attr );
    $dbh->do(qq{SET client_min_messages=WARNING});
    return $dbh;
}

1;
