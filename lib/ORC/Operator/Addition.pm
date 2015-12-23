#!/usr/bin/perl -w

package ORC::Operator::Addition;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;

has 'arguments' => (
  is => 'rw',
  isa => 'ArrayRef',
  required => 1
);

has 'operator' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  default => '+',
);

with 'ORC::Operator';

sub from_parse {
  my $self=shift;
  my $terms=shift;
  if (@$terms < 2) {
    return $terms->[0];
  }
  if (@$terms == 3) {
    return __PACKAGE__->new( operator=>$terms->[1], arguments=>[$terms->[0], $terms->[2] ] );
  }
  my @args = (shift @$terms);
  my $op = shift @$terms;
  while($terms->[1] eq $op) {
    push @args, shift @$terms;
    shift @$terms;
  }
  return __PACKAGE__->new( operator=>$op, arguments=>[ @args, __PACKAGE__->from_parse(@$terms)] );
}

sub negate {
  my $self=shift;
  my @cannot_negate;
  my @new_args;
  for my $arg (@{$self->arguments}) {
    next unless (defined $arg);
    if ($arg->can('negate')) {
      push @new_args, $arg->negate;
    }
    elsif (looks_like_number $arg) {
      push @new_args, 0-$arg;
    }
    else {
      push @cannot_negate, $arg;
    }
  }
  $self->arguments(\@new_args);
  if (@cannot_negate) {
    return ORC::Operator::Subtraction->new(arguments => [ $self, @cannot_negate ]);
  }
  else {
    return $self;
  }
}

sub do {
  my $self=shift;
  my $value;
  my @args=@{$self->arguments};
  $value=shift @args;
  $value=$value->do;
  while(@args) {
    my $addend = shift @args;
    $value = $value + $addend->do;
  }
  return $value;
}

__PACKAGE__->meta->make_immutable;

1;
