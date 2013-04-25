use strict;
use warnings;
package Test::Chado;
{
  $Test::Chado::VERSION = '1.0.0';
}

1;

# ABSTRACT: Build,configure and test chado database backed modules and applications

__END__

=pod

=head1 NAME

Test::Chado - Build,configure and test chado database backed modules and applications

=head1 VERSION

version 1.0.0

=head1 SYNOPSIS

=head3 Write build script(Build.PL) for your module or web application:

   use Module::Build::Chado;

   my $build = Module::Build::Chado->new(
                 module_name => 'MyChadoApp', 
                 license => 'perl', 
                 dist_abstract => 'My chado module'
                 dist_version => '1.0'

   );

  $build->create_build_script;

=head3 Then from the command line:

  perl Build.PL && ./Build test(default is a temporary SQLite database)

It will deploy chado schema in a SQLite database, load fixtures and run all tests)

=head3 In each of the test file(.t) access the schema(Bio::Chado::Schema) object

   use Module::Build::Chado;

   my $schema = Module::Build::Chado->current->schema;

   #do something with it ....

   $schema->resultset('Organism::Organism')->....

=head3 Use for other database backend

B<PostgreSQL>

  ./Build test --dsn "dbi:Pg:dbname=mychado" --user tucker --password booze

B<Oracle>

   ./Build test --dsn "dbi:Oracle:sid=myoracle" --user tucker --password hammer

=head1 DESCRIPTION

This is subclass of L<Module::Build> to configure,  build and test
L<chado|http://gmod.org/wiki/Chado> database backed
perl modules and applications. During the B</Build test>  testing phase it loads some
default fixtures which can be accessed in every test(.t) file using standard
L<DBIx::Class> API.

=head2 Default fixtures loaded

=over

=item List of organisms

Look at the organism.yaml in the shared folder

=item Relationship ontology

OBO relationship types, available here
L<http://bioportal.bioontology.org/ontologies/1042>. 

=item Sequence ontology

Sequence types and features,  available here
L<http://bioportal.bioontology.org/ontologies/1109>

=back

=head2 Accessing fixtures data in test(.t) files

=over

=item Get a L<Bio::Chado::Schema> aka L<DBIx::Class> object

my $schema = Module::Build->current->schema;

isa_ok($schema, 'Bio::Chado::Schema');

=item Access them using L<DBIx::Class> API

  my $row = $schema->resultset('Organism::Organism')->find({species => 'Homo',  genus =>
'sapiens'});

  my $resultset = $schema->resultset('Organism::Organism')->search({});

  my $relonto = $schema->resultset('Cv::Cv')->find({'name' => 'relationship'});

  my $seqonto = $schema->resultset('Cv::Cv')->find({'name' => 'sequence'});

  my $cvterm_rs = $seqonto->cvterms;
  
  while(my $cvterm = $cvterm_rs->next) {
    .....
  }

  You probably will not be accessing them too often,  but mostly needed to load other test
  fixtures.

=back

=head2 Loading custom fixtures

=over

=item *

Create your own subclass and implement either or both of two methods
B<before_all_fixtures> and B<after_all_fixtures>

=over

=item before_all_fixtures

This code will run before any fixture is loaded

=item after_all_fixtures

This code will run after organism data, relationship and sequence ontologies are loaded

=back

   package MyBuilder;
   use base qw/Module::Build::Chado/;

   sub before_all_fixtures {
      my ($self) = @_;
   }

   sub before_all_fixtures {
      my ($self) = @_;
   }

=item *

All the attributes and methods of B<Module::Build> and B<Module::Build::Chado> L<API>
become available through I<$self>.

=back

=head1 ATTRIBUTES

=head2 schema

A L<Bio::Chado::Schema> object.

=head2 dsn

Database connect string,  defaults to a temporary SQLite database.

=head2 user

Database user,  not needed for SQLite backend.

=head2 password

Database password,  not needed for SQLite backend.

=head2 superuser

Database super user, in case the regular use do not have enough permissions for
manipulating the database schema. It defaults to the user attribute.

=head2 superpassword

Similar concept as superuser

=head2 ddl

DDL file for particular backend,  by default comes for SQLite,  Postgresql and Oracle.

=head2 organism_fixuture

Fixture for loading organisms,  by default the distribution comes with a organism.yaml
file.

=head2 rel_fixuture

Relation ontology file in obo_xml format. The distribution includes a relationship.obo_xml
file.

=head2 so_fixuture

Sequence ontology file in obo_xml format. By default,  it includes sofa.obo_xml file.

=head1 METHODS

=head2 connect_hash

Returns a hash with the following connection specific keys ...

=over

=item dsn

=item user

=item password

=item dbi_attributes

=back

=head2 connect_info

Returns an 4 elements array with connection arguments identical to L<DBI>'s B<connect>
method.

=head1 API

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
