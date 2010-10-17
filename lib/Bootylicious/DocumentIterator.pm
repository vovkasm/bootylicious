package Bootylicious::DocumentIterator;

use strict;
use warnings;

use base 'Bootylicious::Iterator';

__PACKAGE__->attr('root');
__PACKAGE__->attr('args' => sub { {} });

use Bootylicious::Document;
use Mojo::ByteStream 'b';

sub new {
    my $self = shift->SUPER::new(@_);

    return $self if $self->elements;

    my $root = $self->root;

    Carp::croak qq/'root' is a required parameter/ unless $root;

    unless (-d $root) {
        warn qq/Warning: Directory '$root' does not exist/;
        return $self;
    }

    my @documents = ();

    my @files = glob "$root/*.*";
    foreach my $file (@files) {
        my $document;

        $file = b($file)->decode('UTF-8');

        next if scalar split(/\./ => $file) > 2;

        local $@;
        eval {
            $document = $self->create_element(path => $file, %{$self->args});
        };
        next if $@;

        push @documents, $document;
    }

    $self->elements(
        [sort { $b->created->epoch <=> $a->created->epoch } @documents]);

    return $self;
}

sub create_element { shift; Bootylicious::Document->new(@_) }

1;
