#!/usr/bin/perl -w

package ORC::Number;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use overload 
  '""' => sub { $_[0]->value }, 
  '+' => sub { $_[0]->value + $_[1] },
  '*' => sub { $_[0]->value * $_[1] },
  '/' => sub { $_[2] ? $_[1] / $_[0]->value : $_[0]->value / $_[1] },
  '0+' => sub { $_[0]->value },
  'eq' => \&_eq;

with 'ORC::Role::Serializable';

has 'value' => (
  is => 'rw',
  required => 1
);

sub _eq {
  my $self=shift;
  my $other=shift;
  my $reversed=shift;
  if (!defined($other)) {
    return;
  }
  elsif ($reversed) {
    return $other eq $self->value;
  }
  else {
    return $self->value eq $other;
  }
}

sub prettyprint {
  my $self=shift;
  return $self->value;
}

sub do {
  my $self=shift;
  return $self->value;
}

sub TO_JSON {
  my $self=shift;
  return $self->value;
}

__PACKAGE__->meta->make_immutable;

1;
