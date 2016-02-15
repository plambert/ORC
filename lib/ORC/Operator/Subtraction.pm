#!/usr/bin/perl -w

package ORC::Operator::Subtraction;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use List::Util qw/all any/;
use Scalar::Util qw/looks_like_number/;

has 'arguments' => (
  is => 'rw',
  isa => 'ArrayRef',
  required => 1
);

has 'operator' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  default => '-',
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

after 'simplify' => sub {
  my $self=shift;
  my $class=$self->meta->name;
  my @arguments;
  my $count=scalar @{$self->arguments};

  # remove undefined values
  if (any { !defined $_ } (@{$self->arguments} )) {
    $self->arguments(grep { defined $_ } (@{$self->arguments}));
    $count=scalar @{$self->arguments};
  }

  # if we have only one operand, we should just become it...
  return $self->arguments->[0] if ($count == 1);

  # can we return addition instead, by negating all arguments?
  if (all { looks_like_number $_ or $_->can('negate') } @{$self->arguments}[1..$#{$self->arguments}]) {
    my $first=shift @{$self->arguments};
    my @rest=map { $_->can('negate') ? $_->negate : 0-$_ } (@{$self->arguments});
    return ORC::Operator::Addition->new(arguments => [ $first, @rest ]);
  }

  for my $arg (@{$self->arguments}) {
    $arg=$arg->simplify if ($arg->can('simplify'));
    if (ref($arg) and $arg->meta->name eq $class) {
      push @arguments, @{$arg->arguments};
    }
    elsif (ref($arg) and $arg->can('negate')) {
      
    }
    else {
      push @arguments, $arg;
    }
  }
  return $self;
};

sub do {
  my $self=shift;
  my $value;
  my @args=@{$self->arguments};
  $value=shift @args;
  while(@args) {
    $value = $value - shift @args;
  }
  return $value;
}

__PACKAGE__->meta->make_immutable;

1;
