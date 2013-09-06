package Test::Chado::Schema::Loader;

use base qw/DBIx::Class::Schema::Loader/;

__PACKAGE__->naming('current');
__PACKAGE__->loader_options(
    rel_name_map => {
        'cvtermsynonym_cvterms' => 'cvtermsynonyms',
        'cvtermprop_cvterms'    => 'cvtermprops'
    }
);

1;

=head1 DESCRIPTION

Its a subclass of L<DBIx::Class::Schema::Loader> primarilly to use with B<Sqlite> DBManager.


