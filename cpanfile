requires "Bio::Chado::Schema" => "0.20000";
requires "DBD::SQLite" => "1.37";
requires "File::Path" => "2.08";
requires "File::ShareDir" => "1.02";
requires "Graph" => "0.94";
requires "IPC::Cmd" => "0.58";
requires "Moo" => "1.001";
requires "MooX::InsideOut" => "0.001002";
requires "MooX::late" => "0.009";
requires "MooseX::Params::Validate" => "0.14";
requires "Path::Class" => "0.18";
requires "Test::DBIx::Class" => "0.38";
requires "Try::Tiny" => "0.03";
requires "XML::Twig" => "3.35";
requires "XML::XPath" => "1.13";
requires "YAML" => "0.70";
requires "namespace::autoclean" => "0.11";
requires "perl" => "5.010";

on 'build' => sub {
  requires "Module::Build" => "0.3601";
};

on 'test' => sub {
  requires "Test::Exception" => "0.31";
  requires "Test::More" => "0.94";
};

on 'configure' => sub {
  requires "Module::Build" => "0.3601";
};

on 'develop' => sub {
  requires "Test::CPAN::Meta" => "0";
};