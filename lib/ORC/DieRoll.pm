#!/usr/bin/perl -w

# using dice expressions from http://lmwcs.com/rptools/wiki/Dice_Expressions
# a die has:
#    face_value: originally rolled value
#    value: the value to use after modifications
#    ignore: undef for dice to use, otherwise the reason it was dropped
#    index: order in which it was rolled (starting with 1, not 0)

package ORC::DieRoll;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;

with 'ORC::Role::Serializable';

has 'value' => (
  is => 'rw',
  builder => sub { shift->face_value },
  lazy => 1,
);

has 'face_value' => (
  is => 'rw',
  required => 1,
);

has 'ignore' => (
  is => 'rw',
  isa => 'Undef|Str',
  default => undef,
);

has 'index' => (
  is => 'rw',
  isa => 'Int',
  required => 1,
);

__PACKAGE__->meta->make_immutable;

1;
