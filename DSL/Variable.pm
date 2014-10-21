#!/usr/bin/perl -w

package DSL::Variable;

use strict;
use warnings;
use namespace::autoclean;
use Moose;

my $instance_cache={};

has 'name' => (
  is => 'ro',
  required => 1,
);

has 'value' => (
  is => 'rw',
);

has 'is_unset' => (
  is => 'rw',
  isa => 'Bool',
  default => 1,
);

sub get {
  if (ref $_[0]) {
    # instance method
    my $self=shift;
    warn "DSL: '" . $self->name . "' is unset\n" unless ($self->is_unset);
    return $self->value;
  }
  else {
    # class method
    my $class=shift;
    my $variable_name=shift;
    # print STDERR "+ GET VARIABLE ", $variable_name, "\n";
    $instance_cache->{$variable_name} //= __PACKAGE__->new(name => $variable_name);
    return $instance_cache->{$variable_name};
  }
}

sub set {
  my $self=shift;
  my $value=shift;
  $self->is_unset(0);
  $self->value($value);
}

__PACKAGE__->meta->make_immutable;

1;
