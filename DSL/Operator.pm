#!/usr/bin/perl -w

package DSL::Operator;

use strict;
use warnings;
use namespace::sweep;
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

sub do {
  my $self=shift;
  my $value;
  my $op_fun={
    '+' => sub { my $v=shift; $v += shift while (@_); return $v; },
    '-' => sub { my $v=shift; $v -= shift while (@_); return $v; },
    '*' => sub { my $v=shift; $v *= shift while (@_); return $v; },
    '/' => sub { my $v=shift; $v /= shift while (@_); return $v; },
  };
  if (exists $op_fun->{$self->operator}) {
    $value = $op_fun->{$self->operator}->(map { $_->can('do') ? $_->do : $_ } @{$self->arguments} );
    return $value;
  }
  else {
    die sprintf("%s: %s: unknown operator!", $0, $self->operator);
  }
}

__PACKAGE__->meta->make_immutable;

1;
