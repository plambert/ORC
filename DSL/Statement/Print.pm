#!/usr/bin/perl -w

package DSL::Statement::Print;

use strict;
use warnings;
use namespace::autoclean;
use Moose;

has 'expression' => (
  is => 'ro',
  required => 1,
);

sub value {
  my $self=shift;
  print $self->expression->value;
}

__PACKAGE__->meta->make_immutable;

1;
