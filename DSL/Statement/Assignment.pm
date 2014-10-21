#!/usr/bin/perl -w

package DSL::Statement::Assignment;

use strict;
use warnings;
use namespace::sweep;
use Moose;

has 'variable' => (
  is => 'rw',
  required => 1,
);

has 'expression' => (
  is => 'rw',
  default => undef,
);

sub value {
  my $self=shift;
  $self->variable->set($self->expression->value);
}

sub prettyprint {
  my $self=shift;
  return sprintf("%s = %s;\n", $self->variable->prettyprint, $self->expression->prettyprint);
}

__PACKAGE__->meta->make_immutable;

1;
