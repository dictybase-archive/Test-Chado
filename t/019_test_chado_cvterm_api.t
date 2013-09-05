use Test::Tester;
use Test::More qw/no_plan/;
use Test::Exception;
use Test::Chado;
use File::ShareDir qw/module_file/;

use_ok 'Test::Chado::Cvterm';

my $preset = module_file( 'Test::Chado', 'eco.tar.bz2' );

subtest 'features of count api' => sub {
    my $schema = chado_schema( custom_fixture => $preset );
    dies_ok { count_cvterm_ok() } 'should die without schema';
    dies_ok { count_cvterm_ok($schema) } 'should die without parameters';
    dies_ok { count_cvterm_ok( $schema, { 'cv' => 'cv_property' } ) }
    'should die without all arguments';

    my $desc = 'should have 299 cvterms';
    check_test(
        sub {
            count_cvterm_ok( $schema, { 'cv' => 'eco', 'count' => 299 },
                $desc );
        },
        {   ok   => 1,
            name => $desc
        },
        $desc
    );

    $desc = 'should have 213 synonyms';
    check_test(
        sub {
            count_synonym_ok( $schema, { 'cv' => 'eco', 'count' => 213 },
                $desc );
        },
        {   ok   => 1,
            name => $desc
        },
        $desc
    );

    $desc = 'should have 7 alt_ids';
    check_test(
        sub {
            count_alt_id_ok( $schema,
                { 'cv' => 'eco', 'count' => 7, db => 'ECO' }, $desc );
        },
        {   ok   => 1,
            name => $desc
        },
        $desc
    );

    $desc = 'should have 68 comments';
    check_test(
        sub {
            count_comment_ok( $schema, { 'cv' => 'eco', 'count' => 68 },
                $desc );
        },
        {   ok   => 1,
            name => $desc
        },
        $desc
    );

    $desc = 'should have 14 subjects';
    check_test(
        sub {
            count_subject_ok( $schema, { 'cv' => 'eco', 'count' => 14, object => 'direct assay evidence', 'relationship' => 'is_a' },
                $desc );
        },
        {   ok   => 1,
            name => $desc
        },
        $desc
    );
    drop_schema();
};

