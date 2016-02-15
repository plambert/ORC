#!/usr/bin/perl -w

package ORC::Undef;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use overload 
  '""' => sub { shift->prettyprint };
#  '+' => sub { 0 + $_[1] };

my $singleton;

sub prettyprint {
  my $self=shift;
  return "\e[31mUNDEF\e[0m";
}

sub do {
  my $self=shift;
  return undef;
}

sub singleton {
  $singleton //= shift->new;
  return $singleton;
}

sub TO_JSON {
  my $self=shift;
  return undef;
}

__PACKAGE__->meta->make_immutable;

1;
