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
  print STDERR "Operator: ", Data::Dumper::Dumper(\@_);
  @terms=@{$_[0]}; shift;
  
  if (@$terms > 1) {
    return __PACKAGE__->new( operator=>'=', arguments=>$terms);
  }
  else {
    return $terms->[0];
  }
}

__PACKAGE__->meta->make_immutable;

1;
