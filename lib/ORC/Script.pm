#!/usr/bin/perl -w

package ORC::Script;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use overload '""' => sub { $_[0]->prettyprint };

has 'statements' => (
  is => 'rw',
  required => 1
);

sub prettyprint {
  my $self=shift;
  return join('', map { $_->prettyprint } @{$self->statements});
}

sub do {
  my $self=shift;
  my $response;
  for my $statement (@{$self->statements}) {
    $response = $statement->do;
  }
  return $response;
}

__PACKAGE__->meta->make_immutable;

1;
