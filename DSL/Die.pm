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

has 'last_total' => (
  is => 'ro',
);

has 'last_results' => (
  is => 'ro',
);

sub prettyprint {
  my $self=shift;
  return sprintf("%d%s%d", $self->count, 'd', $self->pips);
}

sub do {
  my $self=shift;
  my @results;
  my $total=0;
  for (1..$self->count) {
    my $result=int(rand()*$self->pips)+1;
    push @results, $result;
    $total += $result;
  }
  $self->last_total($total);
  $self->last_results(\@results);
  return $total;
}

__PACKAGE__->meta->make_immutable;

1;
