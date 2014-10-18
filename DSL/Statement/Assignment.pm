#!/usr/bin/perl -w

package DSL::Statement::Assignment;

use strict;
use warnings;
use namespace::autoclean;
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

__PACKAGE__->meta->make_immutable;

1;
