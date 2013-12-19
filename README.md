# NAME

Test::Chado - Unit testing for chado database modules and applications

# VERSION

version v4.1.0

# SYNOPSIS

### Start with a perl module

This means you have a module with namespace(with or without double colons), along with __Makefile.PL__ or __Build.PL__ or even __dist.ini__. You have your libraries in
__lib/__ folder and going to write tests in __t/__ folder.
This could an existing or new module, anything would work.

### Write tests 

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

### Run any test commands to test it against chado sqlite

    prove -lv t/dbtest.t

    ./Build test 

    make test

### Run against postgresql

    #Make sure you have a database with enough permissions
    

    prove -l --dsn "dbi:Pg:dbname=testchado;host=localhost"  --user tucker --password halo t/dbtest.t

    ./Build test --dsn "dbi:Pg:dbname=testchado;host=localhost"  --user tucker --password halo

    make test  --dsn "dbi:Pg:dbname=testchado;host=localhost"  --user tucker --password halo

### Run against postgresql without setting any custom server

    prove -l --postgression t/dbtest.t

    ./Build test --postgression

    make test --postgression

# DOCUMENTATION

Use the __quick start__ or pick any of the section below to start your testing. All the source code for this documentation is also available [here](https://github.com/dictyBase/Test-Chado-Guides).

- [Quick start](http://search.cpan.org/perldoc?Test::Chado::Manual::QuickStart.pod) 
- [Testing perl distribution](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithDistribution.pod) 
- [Testing web application](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithWebApp.pod) 
- [Testing with postgresql](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithPostgres) 
- [Loading custom schema(sql statements) for testing](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithCustomSchema) 
- [Loading custom fixtures(test data)](http://search.cpan.org/perldoc?Test::Chado::Manual::TestingWithCustomFixtures) 

# API

### Methods

All the methods are available as __all__ export group. There are two more export groups.

- schema
    - chado\_schema
    - reload\_schema
    - drop\_schema
- manager
    - get\_fixture\_loader\_instance
    - set\_fixture\_loader\_instance
    - get\_dbmanager\_instance
    - set\_dbmanager\_instance

- __chado\_schema(%options)__

    Return an instance of DBIx::Class::Schema for chado database.

    However, because of the way the backends works, for Sqlite it returns a on the fly schema generated from [DBIx::Class::Schema::Loader](http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader), whereas for __Pg__ backend it returns [Bio::Chado::Schema](http://search.cpan.org/perldoc?Bio::Chado::Schema)

    - __options__

        __load\_fixture__ : Pass a true value(1) to load the default fixture, default is false.

        __custom\_fixture__: Path to a custom fixture file made with [DBIx::Class::Fixtures](http://search.cpan.org/perldoc?DBIx::Class::Fixtures). It
        should be a compressed tarball. Currently it is recommended to use
        __tc-prepare-fixture__ script to make custom fixutre so that it fits the expected layout.
        Remember, only one fixture set could be loaded at one time and if both of them specified,
        _custom\_fixture_ will take precedence.

- __drop\_schema__
- __reload\_schema__

    Drops and then reloads the schema.

- set\_fixture\_loader\_type

    Sets the type of fixture loader backend it should use, either of __preset__ or __flatfile__.

- get\_dbmanager\_instance

    Returns an instance of __backend__ class that implements the
    [Test::Chado::Role::HasDBManager](http://search.cpan.org/perldoc?Test::Chado::Role::HasDBManager) Role. 

- set\_dbmanager\_instance

    Sets the dbmanager class that should implement [Test::Chado::Role::HasDBManager](http://search.cpan.org/perldoc?Test::Chado::Role::HasDBManager) Role.

- get\_fixture\_loader\_instance

    Returns an instance of __fixture loader__ class that implements the
    [Test::Chado::Role::Helper::WithBcs](http://search.cpan.org/perldoc?Test::Chado::Role::Helper::WithBcs) Role.

- set\_fixture\_loader\_instance

    Sets __fixture loader__ class that should implement the
    [Test::Chado::Role::Helper::WithBcs](http://search.cpan.org/perldoc?Test::Chado::Role::Helper::WithBcs) Role.

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
