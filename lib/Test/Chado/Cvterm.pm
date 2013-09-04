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
        'is_related'       => \&_is_subject,
    },
    groups => {
        'default' => [
            qw/count_alt_id_ok count_cvterm_ok count_synonym_ok count_subject_ok count_object_ok/
        ]
    }
};

class_has 'test_builder' => (
    is      => 'ro',
    lazy    => 1,
    isa     => TB,
    default => sub { Test::Builder->new }
);

sub _check_params_or_die {
    my ( $class, $args, $param ) = @_;
    my $test_builder = $class->test_builder;
    for my $key (@$args) {
        if ( not defined $param->{$key} ) {
            $test_builder->croak("need $key parameter");
        }
    }
}

sub _count_cvterm {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv count/], $param );

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

sub _count_synonym {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv count/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::Cvtermsynonym';
        }
        else {
            $result_class = 'Cvtermsynonym';
        }
        my $count = $schema->resultset($result_class)->count(
            { 'cv.name' => $param->{cv} },
            { join      => { 'cvterm' => 'cv' } }
        );
        return $test_builder->is_num( $count, $param->{count}, $msg );
    };
}

sub _count_alt_id {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv count/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'General::Dbxref';
        }
        else {
            $result_class = 'Dbxref';
        }
        my $count
            = $schema->resultset($result_class)
            ->count( { 'cv.name' => $param->{cv} },
            { join => { 'cvterm_dbxrefs' => { 'cvterm' => 'cv' } } } );
        return $test_builder->is_num( $count, $param->{count}, $msg );
    };
}

sub _count_subject {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv object count/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::CvtermRelationship';
        }
        else {
            $result_class = 'CvtermRelationship';
        }

        my $query
            = $param->{relationship}
            ? {
            'cv.name'     => $param->{cv},
            'object.name' => $param->{object},
            'type.name'   => $param->{relationship}
            }
            : {
            'cv.name'     => $param->{cv},
            'object.name' => $param->{object}
            };
        my $count = $schema->resultset($result_class)
            ->count( $query, { join => [qw/object type/] } );
        return $test_builder->is_num( $count, $param->{count}, $msg );
    };
}

sub _count_object {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv subject count/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::CvtermRelationship';
        }
        else {
            $result_class = 'CvtermRelationship';
        }

        my $query
            = $param->{relationship}
            ? {
            'cv.name'      => $param->{cv},
            'subject.name' => $param->{subject},
            'type.name'    => $param->{relationship}
            }
            : {
            'cv.name'      => $param->{cv},
            'subject.name' => $param->{subject}
            };
        my $count = $schema->resultset($result_class)
            ->count( $query, { join => [qw/subject type/] } );
        return $test_builder->is_num( $count, $param->{count}, $msg );
    };
}

sub _has_cvterm_synonym {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv term synonym/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::Cvterm';
        }
        else {
            $result_class = 'Cvterm';
        }

        my $count;
        if ( defined $param->{cv} ) {
            $count = $schema->resultset($result_class)->count(
                {   'cv.name'              => $param->{name},
                    'name'                 => $param->{term},
                    'cvtermsynonyms.value' => $param->{synonym},
                    'type.name' => { -in => [qw/BROAD EXACT NARROW RELATED/] }
                },
                { join => [ 'cv', { 'cvtermsynonyms' => 'type' } ] }
            );
        }
        else {
            $count = $schema->resultset($result_class)->count(
                {   'name'                 => $param->{term},
                    'cvtermsynonyms.value' => $param->{synonym},
                    'type.name' => { -in => [qw/BROAD EXACT NARROW RELATED/] }
                },
                { join => [ { 'cvtermsynonyms' => 'type' } ] }
            );
        }
        $test_builder->ok( $count, $msg );
        return $count;
    };
}

sub _has_alt_id {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv term alt_id/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::Cvterm';
        }
        else {
            $result_class = 'Cvterm';
        }

        my $count;
        if ( defined $param->{cv} ) {
            $count = $schema->resultset($result_class)->search(
                {   'cv.name' => $param->{name},
                    'name'    => $param->{term},
                },
                { join => 'cv' }
                )->search_related( 'cvterm_dbxrefs', {} )
                ->count_related( 'dbxref',
                { 'accession' => $param->{alt_id} } );
        }
        else {
            $count
                = $schema->resultset($result_class)
                ->search( { 'name' => $param->{term}, }, { join => 'cv' } )
                ->search_related( 'cvterm_dbxrefs', {} )
                ->count_related( 'dbxref',
                { 'accession' => $param->{alt_id} } );

        }
        $test_builder->ok( $count, $msg );
        return $count;
    };
}

sub _has_comment {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/cv term comment/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::Cvterm';
        }
        else {
            $result_class = 'Cvterm';
        }

        my $count;
        if ( $param->{cv} ) {
            $count = $schema->resultset($result_class)->search(
                {   'cv.name' => $param->{name},
                    'name'    => $param->{term},
                },
                { join => 'cv' }
                )->count_related(
                'cvtermprops',
                {   'value'     => $param->{comment},
                    'type.name' => 'comment',
                    'cv_2.name' => 'cvterm_property_type'
                },
                { join => { 'type' => 'cv' } }
                );
        }
        else {
            $count = $schema->resultset($result_class)->search(
                {   'cv.name' => $param->{name},
                    'name'    => $param->{term},
                },
                { join => 'cv' }
                )->count_related(
                'cvtermprops',
                {   'value'     => $param->{comment},
                    'type.name' => 'comment',
                    'cv_2.name' => 'cvterm_property_type'
                },
                { join => { 'type' => 'cv' } }
                );

        }
        $test_builder->ok( $count, $msg );
        return $count;
    };
}

sub _has_relationship {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/object subject relationship/],
            $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::CvtermRelationship';
        }
        else {
            $result_class = 'CvtermRelationship';
        }

        my $count = $schema->resultset($result_class)->count(
            'object.name'  => $param->{object},
            'subject.name' => $param->{subject},
            'type.name'    => $param->{relationship},
            { join => [ 'subject', 'object', 'type' ] }
        );
        $test_builder->ok( $count, $msg );
        return $count;
        }
}

sub _is_related {
    my ($class) = @_;
    return sub {
        my ( $schema, $param, $msg ) = @_;
        my $test_builder = $class->test_builder;
        $test_builder->croak('need a schema') if !$schema;
        $test_builder->croak('need options')  if !$param;
        $class->_check_params_or_die( [qw/object subject/], $param );

        my $result_class;
        if ( $schema->isa('Bio::Chado::Schema') ) {
            $result_class = 'Cv::CvtermRelationship';
        }
        else {
            $result_class = 'CvtermRelationship';
        }

        my $count = $schema->resultset($result_class)->count(
            {   'object.name'  => $param->{object},
                'subject.name' => $param->{subject}
            },
            { join => [ 'subject', 'object' ] }
        );
        $test_builder->ok( $count, $msg );
        return $count;
        }
}

1;

=head1 API

=head2 Methods

=over

=item

All methods are available as exported subroutines by default

=item

The first two parameters are manadotry.

=back

=over

=item count_cvterm_ok(L<DBIx::Class::Schema>, \%expected, [description])

=over

=item B<parameters>

B<cv>: Name of the cv.

B<count>: Expected number of cvterms in that cv

=back

=item count_synonym_ok(L<DBIx::Class::Schema>, \%expected, [description])

Identical parameters as B<count_cvterm_ok>

=item count_alt_id_ok(L<DBIx::Class::Schema>, \%expected, [description])

Identical parameters as B<count_cvterm_ok>

=item count_subject_ok(L<DBIx::Class::Schema>, \%expected, [description])

Tests the number of children terms for a parent.

=over

=item B<parameters>

B<cv>: Name of the cv.

B<object>: Name of parent cvterm

B<count>: Expected number of children 

B<relationship>: Name of relationship, optional

=back

=item count_object_ok(L<DBIx::Class::Schema>, \%expected, [description])

Tests the number of parent terms for a child.

=over

=item B<parameters>

B<cv>: Name of the cv.

B<subject>: Name of child cvterm

B<expected>: Expected number of parent(s) 

B<relationship>: Name of relationship, optional

=back

=item has_cvterm_synonym(L<DBIx::Class::Schema>, \%expected, [description])

Tests if a cvterm has particular synonym.

=over

=item B<parameters>

B<cv>: Name of the cv, optional.

B<term>: Name of cvterm.

B<synonym>: Name of synonym.

=back

=item has_alt_id(L<DBIx::Class::Schema>, \%expected, [description])

Tests if a cvterm has particular alternate id.

=over

=item B<parameters>

B<cv>: Name of the cv, optional.

B<term>: Name of cvterm.

B<alt_id>: Name of alternate id.

=back

=item has_comment(L<DBIx::Class::Schema>, \%expected, [description])

Tests if a cvterm has particular comment.

=over

=item B<parameters>

B<cv>: Name of the cv, optional.

B<term>: Name of cvterm.

B<comment>: Comment text.

=back

=item has_relationship(L<DBIx::Class::Schema>, \%expected, [description])

Tests if parent and child has a particular relationship

=over

=item B<parameters>

B<cv>: Name of the cv, optional.

B<object>: Name of the parent term.

B<subject>: Name of the child term.

B<relationship>: Name of the relationship term.

=back


=item is_related(L<DBIx::Class::Schema>, \%expected, [description])

Tests if a parent has a particular child or vice versa.

=over

=item B<parameters>

B<object>: Name of the parent term.

B<subject>: Name of the child term.

=back

=back
