#!/usr/bin/perl -w

package DSL::Number;

use strict;
use warnings;
use namespace::autoclean;
use Moose;

has 'value' => (
  is => 'rw',
  required => 1
);

sub prettyprint {
  my $self=shift;
  return $self->value;
}

__PACKAGE__->meta->make_immutable;

1;
