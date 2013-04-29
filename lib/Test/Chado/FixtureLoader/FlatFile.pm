package Test::Chado::FixtureLoader::FlatFile;

use Moo;
use MooX::late;
use Bio::Chado::Schema;
use Test::Chado::Types qw/DbManager/;
use Test::Chado;


has 'dbmanager' => (
is => 'rw',
isa => DbManager
);

sub load_fixtures {
    my ($self) = @_;
}

1;
