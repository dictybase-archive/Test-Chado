package TestBcsHelper;

use Moo;
use MooX::late;
use Test::Chado::Types qw/BCS/;
use Types::Standard qw/Str/;


has 'namespace' => ( is => 'rw', isa => Str);
has 'schema' => ( is => 'rw', isa => BCS);
with 'Test::Chado::Role::Helper::WithBcs';

1;


package main;
use Test::More qw/no_plan/;
use Test::Exception;
use Bio::Chado::Schema;

subtest 'class with BCS helper role' => sub {
    my $schema = Bio::Chado::Schema->connect("dbi:SQLite:dbname=:memory:", "", "");

    my $helper = new_ok('TestBcsHelper');
    lives_ok {$helper->schema($schema)} 'should set the schema';
    lives_ok {$helper->namespace('test-bcs-helper')} 'should set the namespace';
};
