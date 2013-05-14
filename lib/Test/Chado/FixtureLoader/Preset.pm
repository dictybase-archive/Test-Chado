package Test::Chado::FixtureLoader::Preset;
use Moo;
use Test::Chado;
use File::ShareDir qw/module_dir module_file/;
use DBIx::Class::Fixtures;
use Archive::Tar;
use File::Temp;

sub load_fixtures {
    my ($self) = @_;
    my $staging_temp = File::Temp->newdir;

    my $preset = module_file( 'Test::Chado', 'preset.tar.bz2' );
    my $archive = Archive::Tar->new($preset);
    $archive->setcwd($staging_temp);
    $archive->extract;

    my $fixture = DBIx::Class::Fixtures->new(
        {   config_dir =>
                catdir( module_dir('Test::Chado'), 'fixture_config' )
        }
    );
    for my $config_file ( sort { $a <=> $b } $fixture->available_config_sets )
    {
        my $fixture_dir = catdir( $staging_temp, 'fixtures',
            ( ( split /\./, $config_file ) )[0] );
        $fixture->populate(
            {   directory => $fixture_dir,
                no_deploy => 1,
                schema    => $self->schema
            }
        );
    }
}

with 'Test::Chado::Role::Helper::WithBcs';

1;
