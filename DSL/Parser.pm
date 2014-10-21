#!/usr/bin/perl -w

use strict;
use warnings;

package DSL::Parser;

use Moose;
use Carp;


our $grammar=<<'END_OF_GRAMMAR';

start: statement(s) /^\Z/ { $return=$item{'statement(s)'} }

statement: 
  print_statement eos { $item[1] }
| assignment_statement eos { $item[1] }

eos:
  /;\s*/

print_statement:
  /print\s/ expression { "DSL::Statement::Print"->new(expression => $item{expression}) }

assignment_statement:
  variable equals expression { "DSL::Statement::Assignment"->new(variable => $item{variable}, expression => $item{expression}) }

equals: '='

variable:
  /(?!=print[^a-zA-Z0-9_])[a-zA-Z_][a-zA-Z0-9_]*/ { "DSL::Variable"->get($item[1]) }

expression: <leftop: term ('+' | '-') term> { "DSL::Expression"->from_parse(@item) }

term: <leftop: factor ('*' | '/') factor> { "DSL::Expression"->from_parse(@item) }

factor:
  number
| variable
| '(' expression ')' { $item[2] }

op_add: '+' | '-'
op_multiply: '*' | '/'

number: /\d+/ { DSL::Number->new(value => $item[1]) }

END_OF_GRAMMAR

# 1 while $grammar =~ s{\{[^\}\n]*\}}{}g;
# $grammar = "<autotree>\n" . $grammar;
has 'parser' => (
  is => 'ro',
  default => sub { Parse::RecDescent->new($grammar) },
  lazy => 1,
  handles => { parse => 'start' },
);

__PACKAGE__->meta->make_immutable;

1;
