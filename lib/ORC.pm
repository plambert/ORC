#!/usr/bin/perl -w

package ORC;
use Modern::Perl qw/2012/;
use Carp;

our $VERSION='0.40';
our $RNG;

use Moose;
use namespace::sweep;
use Parse::RecDescent;
use ORC::Types;
use ORC::Number;
use ORC::Role::Serializable;
use ORC::Role::RNG;
use ORC::Parser;
use ORC::Variable;
use ORC::Statement::Assignment;
use ORC::Operator;
use ORC::Operator::Addition;
use ORC::Operator::Subtraction;
use ORC::Operator::Multiplication;
use ORC::Operator::Division;
use ORC::Script;
use ORC::RNG;
use ORC::RNG::Mock;
use ORC::RNG::Random;
use ORC::DieExpression;
use ORC::Undef;

has 'parser' => (
  is => 'ro',
  builder => '_default_parser',
  handles => { parse => 'parse' },
);

sub _default_parser {
  return ORC::Parser->new;
}

sub run {
  my $self=shift;
  my $program=shift;
  return $self->parser->parse($program);
}

sub rng {
  my $class=shift;
  my $expected_class='ORC::RNG';
  if (defined $_[0]) {
    my $type=ref $_[0];
    if ($type =~ /${expected_class}/) {
      $RNG=shift;
      return $RNG;
    }
    elsif ($type =~ /::/) {
      croak sprintf "expected class '%s', not '%s'", $expected_class, $type;
    }
    else {
      croak sprintf "expected class '%s'", $expected_class;
    }
  }
  unless (defined $RNG) {
    $RNG=ORC::RNG->singleton(@_);
  }
  return $RNG;
}

sub mock_random_numbers {
  my $class=shift;
  my $numbers;
  if (1==@_ and ref $_[0] eq 'ARRAY') {
    $numbers=shift @_;
  }
  else {
    $numbers=[@_];
  }
  chomp @$numbers;
  $RNG=ORC::RNG::Mock->new(queue => $numbers);
  return $RNG;
}

__PACKAGE__->meta->make_immutable;

1;
