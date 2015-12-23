#!/usr/bin/perl -w

use Modern::Perl qw/2012/;

package ORC;

our $VERSION='0.30';
use Moose;
use namespace::sweep;
use Parse::RecDescent;
use ORC::Role::Serializable;
use ORC::Parser;
use ORC::Variable;
use ORC::Statement::Assignment;
# use ORC::Expression;
use ORC::Number;
use ORC::Operator;
use ORC::Operator::Addition;
use ORC::Operator::Subtraction;
use ORC::Operator::Multiplication;
use ORC::Operator::Division;
use ORC::Script;
use ORC::RandomNumberGenerator;
use ORC::Die;
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

__PACKAGE__->meta->make_immutable;

1;
