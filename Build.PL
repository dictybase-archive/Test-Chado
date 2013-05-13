
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Build,configure and test chado database backed modules and applications",
  "dist_author" => [
    "Siddhartha Basu <biosidd\@gmail.com>"
  ],
  "dist_name" => "Test-Chado",
  "dist_version" => "1.0.0",
  "license" => "perl",
  "module_name" => "Test::Chado",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Bio::Chado::Schema" => "0.20000",
    "DBD::SQLite" => "1.37",
    "File::Path" => "2.08",
    "File::ShareDir" => "1.02",
    "Graph" => "0.94",
    "IPC::Cmd" => "0.58",
    "Module::Path" => "0.09",
    "Module::Runtime" => "0.013",
    "Moo" => "1.001",
    "MooX::HandlesVia" => "0.001000",
    "MooX::InsideOut" => "0.001002",
    "MooX::late" => "0.009",
    "Path::Class" => "0.18",
    "Test::DatabaseRow" => "2.03",
    "Try::Tiny" => "0.03",
    "XML::Twig" => "3.35",
    "XML::XPath" => "1.13",
    "YAML" => "0.70",
    "namespace::autoclean" => "0.11",
    "perl" => "5.010"
  },
  "script_files" => [],
  "share_dir" => {
    "dist" => "share",
    "module" => {
      "Test::Chado" => "share"
    }
  },
  "test_requires" => {
    "Test::Exception" => "0.31",
    "Test::More" => "0.94"
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
