# NAME

Test::Chado - Build,configure and test chado database backed modules and applications

# VERSION

version 1.0.0

# SYNOPSIS

### Write build script(Build.PL) for your module or web application:

    use Module::Build::Chado;

    my $build = Module::Build::Chado->new(
                  module_name => 'MyChadoApp', 
                  license => 'perl', 
                  dist_abstract => 'My chado module'
                  dist_version => '1.0'

    );

    $build->create_build_script;

### Then from the command line:

    perl Build.PL && ./Build test(default is a temporary SQLite database)

It will deploy chado schema in a SQLite database, load fixtures and run all tests)

### In each of the test file(.t) access the schema(Bio::Chado::Schema) object

    use Module::Build::Chado;

    my $schema = Module::Build::Chado->current->schema;

    #do something with it ....

    $schema->resultset('Organism::Organism')->....

### Use for other database backend

__PostgreSQL__

    ./Build test --dsn "dbi:Pg:dbname=mychado" --user tucker --password booze

__Oracle__

    ./Build test --dsn "dbi:Oracle:sid=myoracle" --user tucker --password hammer

# DESCRIPTION

This is subclass of [Module::Build](http://search.cpan.org/perldoc?Module::Build) to configure,  build and test
[chado](http://gmod.org/wiki/Chado) database backed
perl modules and applications. During the __/Build test__  testing phase it loads some
default fixtures which can be accessed in every test(.t) file using standard
[DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) API.

## Default fixtures loaded

- List of organisms

    Look at the organism.yaml in the shared folder

- Relationship ontology

    OBO relationship types, available here
    [http://bioportal.bioontology.org/ontologies/1042](http://bioportal.bioontology.org/ontologies/1042). 

- Sequence ontology

    Sequence types and features,  available here
    [http://bioportal.bioontology.org/ontologies/1109](http://bioportal.bioontology.org/ontologies/1109)

## Accessing fixtures data in test(.t) files

- Get a [Bio::Chado::Schema](http://search.cpan.org/perldoc?Bio::Chado::Schema) aka [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) object

    my $schema = Module::Build->current->schema;

    isa\_ok($schema, 'Bio::Chado::Schema');

- Access them using [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) API

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

## Loading custom fixtures

- Create your own subclass and implement either or both of two methods
__before\_all\_fixtures__ and __after\_all\_fixtures__
    - before\_all\_fixtures

        This code will run before any fixture is loaded

    - after\_all\_fixtures

        This code will run after organism data, relationship and sequence ontologies are loaded

        package MyBuilder;
        use base qw/Module::Build::Chado/;

        sub before_all_fixtures {
           my ($self) = @_;
        }

        sub before_all_fixtures {
           my ($self) = @_;
        }
- All the attributes and methods of __Module::Build__ and __Module::Build::Chado__ [API](http://search.cpan.org/perldoc?API)
become available through _$self_.

# ATTRIBUTES

## schema

A [Bio::Chado::Schema](http://search.cpan.org/perldoc?Bio::Chado::Schema) object.

## dsn

Database connect string,  defaults to a temporary SQLite database.

## user

Database user,  not needed for SQLite backend.

## password

Database password,  not needed for SQLite backend.

## superuser

Database super user, in case the regular use do not have enough permissions for
manipulating the database schema. It defaults to the user attribute.

## superpassword

Similar concept as superuser

## ddl

DDL file for particular backend,  by default comes for SQLite,  Postgresql and Oracle.

## organism\_fixuture

Fixture for loading organisms,  by default the distribution comes with a organism.yaml
file.

## rel\_fixuture

Relation ontology file in obo\_xml format. The distribution includes a relationship.obo\_xml
file.

## so\_fixuture

Sequence ontology file in obo\_xml format. By default,  it includes sofa.obo\_xml file.

# METHODS

## connect\_hash

Returns a hash with the following connection specific keys ...

- dsn
- user
- password
- dbi\_attributes

## connect\_info

Returns an 4 elements array with connection arguments identical to [DBI](http://search.cpan.org/perldoc?DBI)'s __connect__
method.

# Build Status

<a href='https://travis-ci.org/dictyBase/Test-Chado'>
  <img src='https://travis-ci.org/dictyBase/Test-Chado.png?branch=develop'
  alt='Travis CI status'/></a>

<a href='https://coveralls.io/r/dictyBase/Test-Chado'><img
src='https://coveralls.io/repos/dictyBase/Test-Chado/badge.png?branch=develop'
alt='Coverage Status' /></a>

# API

# AUTHOR

Siddhartha Basu <biosidd@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
