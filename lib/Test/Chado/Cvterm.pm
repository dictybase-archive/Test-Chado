package Test::Chado::Cvterm;
use Moo;
use MooX::ClassAttribute;
use Test::Chado::Types qw/TB/;
use Test::Builder;
use Sub::Exporter -setup => {
    exports => {
        'count_cvterm_ok'  => \&_count_cvterm,
        'count_synonym_ok' => \&_count_synonym,
        'count_alt_id_ok'  => \&_count_alt_id,
        'count_subject_ok' => \&_count_subject,
        'count_object_ok'  => \&_count_object,
        'has_synonym'      => \&_has_synonym,
        'has_alt_id'       => \&_has_alt_id,
        'has_comment'      => \&_has_comment,
        'has_relationship' => \&_has_relationship,
        'has_subject'      => \&_has_subject,
        'has_object'       => \&_has_object
    },
    groups => {
        'default' =>
            [qw/has_cv has_dbxref has_cvterm has_feature has_featureloc/]
    }
};

class_has 'test_builder' => (
    is      => 'ro',
    lazy    => 1,
    isa     => TB,
    default => sub { Test::Builder->new }
);

sub _count_cvterm {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;

        for my $key ( keys %$param ) {
            if ( not defined $param->{$key} ) {
                $test_builder->croak("need $key parameter");
            }
        }

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::Cvterm';
        }
        else {
            $result_class = 'Cvterm';
        }
        my $count = $schema->resultset($result_class)
            ->count( { 'cv.name' => $param->{cv} }, { join => 'cv' } );
        return $test_builder->is_num( $count, $param->{count}, $msg );
    };
}

=head1 API

=head2 Methods

=over

=item

All methods are available as exported subroutines by default

=back

=item

The first two parameters are manadotry.

=back

=over

=item count_cvterm_ok(L<DBIx::Class::Schema>, \%parameters, [description])

=over

=item B<parameters>

B<cv>: Name of the cv.

B<count>: Expected number of cvterms in that cv

=back

=item count_synonym_ok(L<DBIx::Class::Schema>, \%parameters, [description])

Identical parameters as B<count_cvterm_ok>

=item count_alt_id_ok(L<DBIx::Class::Schema>, \%parameters, [description])

Identical parameters as B<count_cvterm_ok>

=item count_subject_ok(L<DBIx::Class::Schema>, \%parameters, [description])

Tests the number of children terms for a parent.

=over

=item B<parameters>

B<cv>: Name of the cv.

B<object>: Name of parent cvterm

B<expected>: Expected number of children 

B<relationship>: Name of relationship, parametersal

=back

=item count_object_ok(L<DBIx::Class::Schema>, \%parameters, [description])

Tests the number of parent terms for a child.

=over

=item B<parameters>

B<cv>: Name of the cv.

B<subject>: Name of child cvterm

B<expected>: Expected number of parent(s) 

B<relationship>: Name of relationship, parametersal

=back

=item has_cvterm_synonym(L<DBIx::Class::Schema>, \%parameters, [description])

Tests if a cvterm has particular synonym.

=over

=item B<parameters>

B<cv>: Name of the cv, parametersal.

B<term>: Name of cvterm.

B<synonym>: Name of synonym.

=back

=item has_alt_id(L<DBIx::Class::Schema>, \%parameters, [description])

Tests if a cvterm has particular alternate id.

=over

=item B<parameters>

B<cv>: Name of the cv, parametersal.

B<term>: Name of cvterm.

B<alt_id>: Name of alternate id.

=back

=item has_comment(L<DBIx::Class::Schema>, cvterm name, [description])

Tests if a cvterm has particular comment.

=over

=item B<parameters>

B<cv>: Name of the cv, parametersal.

B<term>: Name of cvterm.

B<comment>: Comment text.

=back

=item has_relationship(L<DBIx::Class::Schema>, \%parameters, [description])

Tests if parent and child has a particular relationship

=over

=item B<parameters>

B<cv>: Name of the cv, parametersal.

B<object>: Name of the parent term.

B<subject>: Name of the child term.

B<relationship>: Name of the relationship term.

=back

=item has_subject(L<DBIx::Class::Schema>, \%parameters, [description])

Tests if a parent has a particular child

=over

=item B<parameters>

B<cv>: Name of the cv, parametersal.

B<object>: Name of the parent term.

B<subject>: Name of the child term.

B<relationship>: Name of the relationship term, parametersal.


=item has_object(L<DBIx::Class::Schema>, feature name, [description])

Tests if a child has a particular parent

=over

=item B<parameters>

B<cv>: Name of the cv, parametersal.

B<object>: Name of the parent term.

B<subject>: Name of the child term.

B<relationship>: Name of the relationship term, parametersal.


=back
