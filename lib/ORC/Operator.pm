#!/usr/bin/perl -w

package ORC::Operator;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose::Role;

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

#__PACKAGE__->meta->make_immutable;

1;
