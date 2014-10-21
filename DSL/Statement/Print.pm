#!/usr/bin/perl -w

package DSL::Statement::Print;

use strict;
use warnings;
use namespace::autoclean;
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

__PACKAGE__->meta->make_immutable;

1;
