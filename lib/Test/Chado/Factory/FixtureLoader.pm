package Test::Chado::Factory::FixtureLoader;

use strict;
use Module::Load qw/load/;
use Module::Path qw/module_path/;
use Module::Runtime qw/compose_module_name/;

sub get_instance {
    my ($class,$arg) = @_;
    die "need a type of fixture loader\n" if !$arg;
    
    $arg = ucfirst lc($arg);
    my $module = compose_module_name('Test::Chado::FixtureLoader',$arg);
    my $module_path = module_path($module);
    die "could not find $module\n" if not defined $module_path;

    load $module;
    return $module->new;
}

1;
