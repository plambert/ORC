#!/usr/bin/perl -w

package DSL::Die;

use strict;
use warnings;
use namespace::sweep;
use Moose;
use overload '""' => sub { $_[0]->prettyprint };

has 'count' => (
  is => 'rw',
  default => 1,
);

has 'pips' => (
  is => 'rw',
  required => 1,
);

sub prettyprint {
  my $self=shift;
  return sprintf("%d%s%d", $self->count, 'd', $self->pips);
}

__PACKAGE__->meta->make_immutable;

1;
