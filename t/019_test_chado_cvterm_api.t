use Test::Tester;
use Test::More qw/no_plan/;
use Test::Exception;
use Test::Chado;
use File::ShareDir qw/module_file/;

use_ok 'Test::Chado::Cvterm';

my $preset = module_file( 'Test::Chado', 'cvpreset.tar.bz2' );

subtest 'features of has_cv method' => sub {
    my $schema = chado_schema( custom_fixture => $preset );
    dies_ok { count_cvterm_ok() } 'should die without schema';
    dies_ok { count_cvterm_ok($schema) } 'should die without parameters';
    dies_ok { count_cvterm_ok($schema, {'cv' => 'cv_property'}) } 'should die without all arguments';

    my $desc = 'should have twenty cvterms';
    check_test(
        sub { count_cvterm_ok $schema, {'cv' => 'cv_property', 'count' => 20}, $desc },
        {   ok   => 1,
            name => $desc
        },
        $desc
    );
    drop_schema();
};

