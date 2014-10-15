#!/usr/bin/perl -w

use strict;
use warnings;

package DSL;

# Enable warnings within the Parse::RecDescent module.
$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.
# $::RD_TRACE  = 90; # Trace behaviour to help fix problems.


our $grammar=<<'END_OF_GRAMMAR';

start: statement(s) /^\Z/ { $return=$item{'statement(s)'} }

statement: ( print_statement | assignment_statement ) eos { $item[1] }
# | <error: no statement at byte $thisoffset>

eos:
  /;\s*/

print_statement:
  /print\s/ <commit> expression { [ 'print', $item{expression} ] }

assignment_statement:
  variable_name equals <commit> expression { [ 'assign', $item{variable_name}, $item{expression} ] }

equals: '='

variable_name:
  /(?!=print[^a-zA-Z0-9_])[a-zA-Z0-9][a-zA-Z0-9_]*/ { bless { 'name' => $item[1] }, 'D20DSL::Variable' }

expression:
  /[0-9+\-\/\*]+/ /\s*/ { $item[1] }

END_OF_GRAMMAR


sub new {
  my $class=shift;
  my $opts={ @_ };
  my $dsl={
    # default options go here
  };
  while (@_>1) {
    my ($key, $value) = (shift @_, shift @_);
    $dsl->{$key}=$value;
  }
  $dsl->{parser} = Parse::RecDescent->new($grammar) unless (exists $dsl->{parser});
  bless $dsl, $class;
  return $dsl;
}

sub parse {
  my $self=shift;
  return $self->{parser}->start(@_);
}

package DSL::Variable;

sub new {
  my $class=shift;
  my $name=shift;
  my $new={ name => $name };
  bless $new, $class;
  return $new;
}

1;

