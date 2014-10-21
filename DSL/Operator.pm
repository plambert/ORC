#!/usr/bin/perl -w

package DSL::Operator;

use strict;
use warnings;
use namespace::autoclean;
use Moose;

has 'operator' => (
  is => 'rw',
  required => 1
);

has 'arguments' => (
  is => 'rw',
  required => 1
);

sub from_parse {
  my $self=shift;
  my @terms;
  @terms=@{$_[0]}; shift;
  if (@terms < 2) {
    return $terms[0];
  }
  if (@terms == 3) {
    return __PACKAGE__->new( operator=>$terms[1], arguments=>[$terms[0], $terms[2] ] );
  }
  my @args = (shift @terms);
  my $op = shift @terms;
  while($terms[1] eq $op) {
    push @args, shift @terms;
    shift @terms;
  }
  return __PACKAGE__->new( operator=>$op, arguments=>[ @args, __PACKAGE__->from_parse(@terms)] );
  
}

sub prettyprint {
  my $self=shift;
  return join(" " . $self->operator . " ", map { $_->prettyprint } @{$self->arguments});
}

__PACKAGE__->meta->make_immutable;

1;
