#!/usr/bin/perl -w

package DSL::Statement::Print;

use strict;
use warnings;
use namespace::sweep;
use Moose;

has 'expressions' => (
  is => 'ro',
  required => 1,
);

sub value {
  my $self=shift;
  my @expressions;
  if (ref $self->expressions eq 'ARRAY') {
    @expressions=@{$self->expressions};
  }
  elsif (defined $self->expressions and !(ref $self->expressions)) {
    @expressions=( $self->expressions );
  }
  for my $expression (@expressions) {
    printf "%s\n", $expression->value;
  }
  return $expressions[-1]->value;
}

sub prettyprint {
  my $self=shift;
  return "print " . join(', ', map { $_->prettyprint } (@{$self->expressions}) ) . ";\n";
}

sub do {
  my $self=shift;
  my @results;
  for my $expression (@{$self->expressions}) {
    my $result=$expression->do;
    push @results, $result;
    # print $result;
  }
  return join(", ", @results) . "\n";
}

__PACKAGE__->meta->make_immutable;

1;
