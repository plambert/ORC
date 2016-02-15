#!/usr/bin/perl -w

package ORC::Statement::Assignment;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;

with 'ORC::Role::Serializable';

has 'variable' => (
  is => 'rw',
  required => 1,
);

has 'expression' => (
  is => 'rw',
  default => undef,
);

sub value {
  my $self=shift;
  $self->variable->set($self->expression->value);
}

sub prettyprint {
  my $self=shift;
  return sprintf("%s = %s;\n", $self->variable->prettyprint, $self->expression->prettyprint);
}

sub do {
  my $self=shift;
  $self->variable->value($self->expression->do);
}

sub TO_JSON {
  my $self=shift;
  my $data={ _class => [$self->meta->linearized_isa] };
  for my $attr ($self->meta->get_all_attributes) {
    $data->{$attr}=$self->$attr;
  }
  return $data;
}

__PACKAGE__->meta->make_immutable;

1;
