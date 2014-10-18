#!/usr/bin/perl -w

package DSL::Expression;

use strict;
use warnings;
use namespace::autoclean;
use Moose;

has 'expression' => (
  is => 'ro',
  required => 1,
);

sub from_parse {
  my $self=shift;
  shift;
  my @expression;
  if (ref $_[0] eq 'ARRAY') {
    my $arg=shift;
    if (ref $arg->[0] eq 'ARRAY') {
      @expression=@{$arg->[0]} or die "ruh-roh!";
    }
    else {
      @expression=($arg->[0]);
    }
  }
  else {
    @expression=@_;
  }
  if (@expression > 2) {
    my $idx=0;
    while($idx<=$#expression-1) {
      @expression[$idx+1,$idx] = @expression[$idx,$idx+1];
      $idx += 2;
    }
    return DSL::Expression->new(expression => \@expression)
  }
  else {
    return $expression[0];
  }
}

__PACKAGE__->meta->make_immutable;

1;
