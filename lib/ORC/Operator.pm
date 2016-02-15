#!/usr/bin/perl -w

package ORC::Operator;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose::Role;
use Carp;

requires 'operator';
requires 'do';

with 'ORC::Role::Serializable';

has 'arguments' => (
  is => 'rw',
  required => 1
);

sub _call_maybe {
  my $thing=shift;
  my $methods='ARRAY' eq ref $_[0] ? shift : [ shift ];
  if (!defined $thing) {
    return ORC::Undef->singleton;
  }
  elsif (!ref $thing) {
    return $thing;
  }
  while (@$methods) {
    my $method=shift @$methods;
    if (eval { $thing->can($method) }) {
      return $thing->$method(@_);
    }
  }
  return $thing;
}

sub prettyprint {
  my $self=shift;
  return join(" " . $self->operator . " ", map { _call_maybe($_, ['prettyprint','value']) } @{$self->arguments});
}

sub simplify {
  my $self=shift;
  my $class=$self->meta->name;
  my @arguments;
  for my $arg (@{$self->arguments}) {
    $arg=$arg->simplify if ($arg->can('simplify'));
    if (ref($arg) and $arg->meta->name eq $class) {
      push @arguments, @{$arg->arguments};
    }
    else {
      push @arguments, $arg;
    }
  }
  return $self;
}

#__PACKAGE__->meta->make_immutable;

1;
