#!/usr/bin/perl -w

use strict;
use Marpa::R2;
use Data::Dumper;
use lib '.';
use DSL;

my $grammar_text=join('', <DATA>);
my $g = Marpa::R2::Scanless::G->new({
        action_object  => 'DSL',
        source         => \$grammar_text,
});

my $re = Marpa::R2::Scanless::R->new({trace_values=>1,trace_terminals => 1,grammar => $g });
# my $input = "a = 7\nb = 6\nc = a * 4 + b - 2\nprint a\nprint b\nprint c\n";
my $input="a = 1";

print "Trying to parse:\n$input\n\n";
$re->read(\$input);
my $value = $re->value;
print "Output:\n".Dumper($value);

__DATA__

:default      ::= action => action_default
lexeme default  = action => [ start, length, value ]
                  latm => 1

:start        ::= script

script        ::= statements (OPT_EOL)

statements    ::= statement+                                separator => OPT_SEP

statement     ::= VARIABLE (OPT_WS) (EQUALS) (OPT_WS) expression (OPT_EOL)               action => assignment
                | PRINT (WS) expression (OPT_WS)                          action => print_cmd

expression    ::= parenthesized_expression
                | strong_operator_expression
                | weak_operator_expression
                | atomic_expression

parenthesized_expression
              ::= LEFT_PAREN (OPT_WS) expression (OPT_WS) RIGHT_PAREN         action => paren     assoc => group

weak_operator_expression
              ::= expression (OPT_WS) weak_operator (OPT_WS) expression       action => op

strong_operator_expression
              ::= expression (OPT_WS) strong_operator (OPT_WS) expression     action => op

atomic_expression
              ::= dice_expression
               || VARIABLE
                | NUMBER

weak_operator ::= OP_ADDITION
                | OP_SUBTRACTION

strong_operator
              ::= OP_MULTIPLICATION
                | OP_DIVISION

dice_expression
              ::= dice_drop
                | dice_keep
                | dice_reroll
                | dice_success
                | dice_explode
                | dice_explode_success
                | dice_open
                | dice_simple

dice_simple   ::= NUMBER ('d') NUMBER                       action => dice_simple             assoc => left
dice_drop     ::= NUMBER ('d') NUMBER ('d') NUMBER          action => dice_drop               assoc => left
dice_keep     ::= NUMBER ('d') NUMBER ('k') NUMBER          action => dice_keep
dice_reroll   ::= NUMBER ('d') NUMBER ('r') NUMBER          action => dice_reroll
dice_success  ::= NUMBER ('d') NUMBER ('s') NUMBER          action => dice_success
dice_explode  ::= NUMBER ('d') NUMBER ('e')                 action => dice_explode
dice_explode_success
              ::= NUMBER ('d') NUMBER ('es') NUMBER         action => dice_explode_success
dice_open     ::= NUMBER ('d') NUMBER ('o')                 action => dice_open

# dice_expression
#                 ::= DICE_SIMPLE                               action => dice_expression
#                   | DICE_MODIFIED                             action => dice_expression
#                   | DICE_PARAM                                action => dice_expression
#                   | DICE_PARAM_ES                             action => dice_expression
#
# DICE_SIMPLE       ~ [\d]+ DICE_SIMPLE_1
# DICE_SIMPLE_1     ~ 'd' DICE_SIMPLE_2
# DICE_SIMPLE_2     ~ [\d]+
#
# DICE_MODIFIED     ~ [\d]+ DICE_MODIFIED_1
# DICE_MODIFIED_1   ~ 'd' DICE_MODIFIED_2
# DICE_MODIFIED_2   ~ [\d]+ DICE_MODIFIED_3
# DICE_MODIFIED_3   ~ [eo]
#
# DICE_PARAM        ~ [\d]+ DICE_PARAM_1
# DICE_PARAM_1      ~ 'd' DICE_PARAM_2
# DICE_PARAM_2      ~ [\d]+ DICE_PARAM_3
# DICE_PARAM_3      ~ [eo]
#
# DICE_PARAM_ES     ~ [\d]+ DICE_PARAM_ES_1
# DICE_PARAM_ES_1   ~ 'd' DICE_PARAM_ES_2
# DICE_PARAM_ES_2   ~ [\d]+ DICE_PARAM_ES_3
# DICE_PARAM_ES_3   ~ 'es' DICE_PARAM_ES_4
# DICE_PARAM_ES_4   ~ [\d]+

VARIABLE        ~ [a-z] VARIABLE_more
VARIABLE_more   ~ [a-z0-9_]*
NUMBER          ~ [\d]+
PRINT           ~ 'print'
LEFT_PAREN      ~ '('
RIGHT_PAREN     ~ ')'
OP_ADDITION     ~ '+'
OP_SUBTRACTION  ~ '-'
OP_MULTIPLICATION
                ~ '*'
OP_DIVISION     ~ '/'
EQUALS          ~ '='
# :discard        ~ WS#
WS              ~ [ \t]+
OPT_WS          ~ [ \t]*
OPT_EOL         ~ [\n]+
OPT_SEP         ~ [;\n]+
