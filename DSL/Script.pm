#!/usr/bin/perl -w

package DSL::Script;

use strict;
use warnings;
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
