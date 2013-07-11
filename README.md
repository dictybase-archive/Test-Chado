# NAME

Test::Chado - Unit testing for chado database modules and applications

# VERSION

version 1.0.0

# SYNOPSIS

#### Start with a perl module

This means you have a module with namespace(with or without double colons), along with __Makefile.PL__ or __Build.PL__ or even __dist.ini__. You have your libraries in
__lib/__ folder and going to write tests in __t/__ folder.
This could an existing or new module, anything would work.

#### Write tests 

It should be in your .t file(t/dbtest.t for example)

    use Test::More;
    use Test::Chado;
    use Test::Chado::Common;

    my $schema = chado_schema(load_fixtures => 1);

    has_cv($schema,'sequence', 'should have sequence ontology');
    has_cvterm($schema, 'part_of', 'should have term part_of');
    has_db($schema, 'SO', 'should have SO in db table');
    has_dbxref($schema, '0000010', 'should have 0000010 in dbxref');

    drop_schema();

#### Run any test commands to test it against chado sqlite

    prove -lv t/dbtest.t

    ./Build test 

    make test

#### Run against postgresql

    #Make sure you have a database with enough permissions
    

    prove -l --dsn "dbi:Pg:dbname=testchado;host=localhost"  --user tucker --password halo t/dbtest.t

    ./Build test --dsn "dbi:Pg:dbname=testchado;host=localhost"  --user tucker --password halo

    make test  --dsn "dbi:Pg:dbname=testchado;host=localhost"  --user tucker --password halo

#### Run against postgresql without setting any custom server

    prove -l --postgression t/dbtest.t

    ./Build test --postgression

    make test --postgression

# DOCUMENTATION

Use the __quick start__ or pick any of the section below to start your testing. All the source code for this documentation is also available [here](https://github.com/dictyBase/Test-Chado-Guides).

- [Quick start](#lib/Test/Chado/Manual/QuickStart.pod) 
- [Testing perl distribution](#lib/Test/Chado/Manual/TestingWithDistribution.pod) 
- [Testing web application](#lib/Test/Chado/Manual/TestingWithWebApp.pod) 
- [Testing with postgresql ](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithPostgres) 
- [Loading custom schema for tesing ](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithCustomSchema) 
- [Loading custom fixtures ](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithCustomFixtures) 

# API

### Attributes

- __dbmanager\_instance__

    Instance of a backend manager that implements [Test::Chado::Role::HasDBManager](http://search.cpan.org/perldoc?Test::Chado::Role::HasDBManager) role, currently either of Sqlite or Pg backend will be available.

- __is\_schema\_loaded__

    Flag to check the loading status of chado schema

- __fixture\_loader\_instance__

    Insatnce of [Test::Chado::FixtureLoader::Preset](http://search.cpan.org/perldoc?Test::Chado::FixtureLoader::Preset) by default.

- __fixture\_loader__

    Type of fixture loader, could be either of __preset__ and flatfile. By default it is __preset__

### Methods

All the methods are available as exported subroutines by default

- __chado\_schema(%options)__

    Return an instance of DBIx::Class::Schema for chado database.

    However, because of the way the backends works, for Sqlite it returns a on the fly schema generated from [DBIx::Class::Schema::Loader](http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader), whereas for __Pg__ backend it returns [Bio::Chado::Schema](http://search.cpan.org/perldoc?Bio::Chado::Schema)

    - __options__

        __load\_fixture__ : Pass a true value(1) to load the default fixture

- __drop\_schema__
- __reload\_schema__

    Drops and then reloads the schema.

- set\_fixture\_loader

    Sets the type of fixture loader backend it should use, either of __preset__ or __flatfile__.

# Build Status

<a href='https://travis-ci.org/dictyBase/Test-Chado'>
  <img src='https://travis-ci.org/dictyBase/Test-Chado.png?branch=develop'
  alt='Travis CI status'/></a>

<a href='https://coveralls.io/r/dictyBase/Test-Chado'><img
src='https://coveralls.io/repos/dictyBase/Test-Chado/badge.png?branch=develop'
alt='Coverage Status' /></a>

# AUTHOR

Siddhartha Basu <biosidd@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
