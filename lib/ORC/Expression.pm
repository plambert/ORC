#!/usr/bin/perl -w

package ORC::Expression;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;

with 'ORC::Role::Serializable';

has 'expression' => (
  is => 'ro',
  required => 1,
);

sub from_parse {
  my $self=shift;
  shift;
  print STDERR "Expression start: ", Data::Dumper::Dumper(\@_), "\n";
  my @expression;
  if (ref $_[0] eq 'ARRAY') {
    my $arg=shift;
    print STDERR "Expression: deref: ", Data::Dumper::Dumper($arg);
    if (ref $arg->[0] eq 'ARRAY') {
      @expression=@{$arg->[0]} or die "ruh-roh!";
    }
    else {
      @expression=@$arg;
    }
  }
  else {
    @expression=@_;
  }
  print STDERR "Expression during parse: ", Data::Dumper::Dumper(\@expression), "\n";
  if (@expression > 2) {
    my $idx=0;
    while($idx<=$#expression-1) {
      @expression[$idx+1,$idx] = @expression[$idx,$idx+1];
      $idx += 2;
    }
    print STDERR "Expression end (complex): ", Data::Dumper::Dumper(\@expression), "\n";
    return ORC::Expression->new(expression => \@expression)
  }
  else {
    print STDERR "Expression end (simple): ", Data::Dumper::Dumper($expression[0]), "\n";
    return $expression[0];
  }
}

sub prettyprint {
  my $self=shift;
  
}

__PACKAGE__->meta->make_immutable;

1;
