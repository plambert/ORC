#!/usr/bin/perl -w

package ORC::Operator::Division;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;

has 'arguments' => (
  is => 'rw',
  required => 1
);

has 'operator' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  default => '/',
);

with 'ORC::Operator';

sub from_parse {
  my $self=shift;
  my $terms=shift;
  return __PACKAGE__->new(arguments=>$terms );
}

sub do {
  my $self=shift;
  my $value;
  my @args=@{$self->arguments};
  $value=shift @args;
  $value=$value->do;
  while(@args) {
    my $factor=shift @args;
    $value = $value / $factor->do;
  }
  return $value;
}

__PACKAGE__->meta->make_immutable;

1;
