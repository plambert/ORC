#!/usr/bin/perl -w

use Modern::Perl qw/2012/;

package ORC;

our $VERSION='0.30';
use Moose;
use namespace::sweep;
use Parse::RecDescent;
use ORC::Parser;
use ORC::Variable;
use ORC::Statement::Assignment;
use ORC::Statement::Print;
# use ORC::Expression;
use ORC::Number;
use ORC::Operator;
use ORC::Script;
use ORC::Die;

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
