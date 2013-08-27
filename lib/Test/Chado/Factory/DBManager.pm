package Test::Chado::Factory::DBManager;

use strict;
use Module::Load qw/load/;
use Module::Path qw/module_path/;
use Module::Runtime qw/compose_module_name/;

sub get_instance {
    my ($class,$arg) = @_;
    die "need a type of db manager\n" if !$arg;
    
    $arg = ucfirst lc($arg);
    my $module = compose_module_name('Test::Chado::DBManager',$arg);
    my $module_path = module_path($module);
    die "could not find $module\n" if not defined $module_path;

    load $module;
    return $module->new;
}

1;
