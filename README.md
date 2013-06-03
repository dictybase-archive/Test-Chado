# NAME

Test::Chado - Unit testing for chado database modules and applications

# VERSION

version 1.0.0

# SYNOPSIS

# DESCRIPTION

# Build Status

<a href='https://travis-ci.org/dictyBase/Test-Chado'>
  <img src='https://travis-ci.org/dictyBase/Test-Chado.png?branch=develop'
  alt='Travis CI status'/></a>

<a href='https://coveralls.io/r/dictyBase/Test-Chado'><img
src='https://coveralls.io/repos/dictyBase/Test-Chado/badge.png?branch=develop'
alt='Coverage Status' /></a>

# API

## Attributes

- dbmanager\_instance

    Instance of a backend manager that implements [Test::Chado::Role::HasDBManager](http://search.cpan.org/perldoc?Test::Chado::Role::HasDBManager) role, currently either of Sqlite or Pg backend will be available.

- is\_schema\_loaded

    Flag to check the loading status of chado schema

- fixture\_loader\_instance 

    Insatnce of [Test::Chado::FixtureLoader::Preset](http://search.cpan.org/perldoc?Test::Chado::FixtureLoader::Preset) by default.

- fixture\_loader

    Type of fixture loader, could be either of __preset__ and flatfile. By default it is __preset__

## Methods

All the methods are available as exported subroutines by default

- chado\_schema(%options)

    Return an instance of DBIx::Class::Schema for chado database.

    However, because of the way the backends works, for Sqlite it returns a on the fly schema generated from [DBIx::Class::Schema::Loader](http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader), whereas for __Pg__ backend it returns [Bio::Chado::Schema](http://search.cpan.org/perldoc?Bio::Chado::Schema)

    - options

        __load\_fixture__ : Pass a true value(1) to load the default fixture

- drop\_schema
- reload\_schema

    Drops and then reloads the schema.

- set\_fixture\_loader

    Sets the type of fixture loader backend it should use, either of __preset__ or __flatfile__.

# AUTHOR

Siddhartha Basu <biosidd@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
