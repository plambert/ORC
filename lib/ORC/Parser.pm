#!/usr/bin/perl -w

use Modern::Perl qw/2012/;

package ORC::Parser;

use Moose;
use Carp;


our $grammar=do { local $/; <DATA> };

# 1 while $grammar =~ s{\{[^\}\n]*\}}{}g;
# $grammar = "<autotree>\n" . $grammar;
has 'parser' => (
  is => 'ro',
  default => sub { Parse::RecDescent->new($grammar) },
  lazy => 0,
#  handles => { parse => 'start' },
);

sub parse {
  my $self=shift;
  my $method;
  my $text;
  my $rng;
  my $opts={ line => 1, method => 'start' };
  if ($_[0] and ref $_[0] eq 'HASH') {
    $opts->{$_}=$_[0]->{$_} for (keys %{$_[0]});
    shift @_;
  }
  $method=$opts->{method};
  $text=shift @_;
  return $self->parser->$method($text, $opts->{line}, @_);
}

sub expression {
  my $class=shift @_;
  my @item=@{shift @_};
  if (ref $item[1] ne 'ARRAY') {
    return $item[1];
  }
  elsif (@{$item[1]} == 1) {
    my $result=$item[1]->[0];
    while (ref $result eq 'ARRAY' and @$result == 1) {
      $result=$result->[0];
    }
    return $result;
  }
  else {
    my @it=@{$item[1]};
    my $result=shift @it;
    while(@it) {
      my $op=shift @it;
      my $arg=shift @it;
      if ($op eq '-' and ref $arg and $arg->can('negate')) {
        $op='+';
        $arg=$arg->negate;
      }
      if ($op eq '+') {
        $result=ORC::Operator::Addition->new(arguments=>[$result, $arg]);
      }
      elsif ($op eq '-') {
        $result=ORC::Operator::Subtraction->new(arguments=>[$result, $arg]);
      }
    }
    return $result->simplify;
  }
}

__PACKAGE__->meta->make_immutable;

1;

__DATA__


{
  my $escape_map={ 'a' => "\a", 'e' => "\e", 'f' => "\f", 'n' => "\n", 'r' => "\r", 't' => "\t" };
  my $delimiter_map={
     '{' =>  '}',
     '(' =>  ')',
     '[' =>  ']',
     '<' =>  '>',
    '{{' => '}}',
    '((' => '))',
    '[[' => ']]',
    '<<' => '>>',
  };
}

start: <skip:'[ \t]*'> statement(s) /^\Z/ { ORC::Script->new(statements => $item{'statement(s)'}) }

statement: 
  <skip:'[ \t]*'> assignment_statement <skip:''> eos <skip:$item[-3]> { $item{assignment_statement} }
| <skip:'[ \t]*'> expression <skip:''> eos <skip:$item[-3]> { $item{expression} }

eos: <skip:'[ \t]*'> /;\s*/ | <skip:'[ \t]*'> /^\Z/ | <skip:'[ \t]*'> /\n/ | <error>

assignment_statement:
  identifier /\s*/ equals /\s*/ expression { ORC::Statement::Assignment->new(variable => $item{identifier}, expression => $item{expression}) }

equals: '='

identifier:
  /[a-zA-Z_][a-zA-Z0-9_]*/ { "ORC::Variable"->get($item[1]) }

expression: <leftop: factor /([\+\-])\s*/ factor>
  { 
    ORC::Parser->expression(\@item);
  }

factor: <leftop: term /([\*\/])\s*/ term>
  { 
    if (ref $item[1] ne 'ARRAY') {
      $return=$item[1];
    }
    elsif (@{$item[1]} == 1) {
      $return=$item[1]->[0];
      while (ref $return eq 'ARRAY' and @$return == 1) {
        $return=$return->[0];
      }
    }
    else {
      my @it=@{$item[1]};
      $return=shift @it;
      while(@it) {
        my $op=shift @it;
        my $arg=shift @it;
        if ($op eq '*') {
          $return=ORC::Operator::Multiplication->new(arguments=>[$return, $arg]);
        }
        elsif ($op eq '/') {
          $return=ORC::Operator::Division->new(arguments=>[$return, $arg])
        }
      }
      $return=$return->simplify;
    }
  }

term:
  die_expression
| number
| identifier
| '(' <commit> expression ')' { $item{expression} }
| <error>

die_expression:
    <skip:''> number 'd' number (die_expression_modifier)(?) <skip:$item[1]>
      {
        my $die;
        if ($item[5] and ref $item[5] eq 'ARRAY') {
          $die=$item[5]->[0];
        }
        $die->{count} = $item[2];
        $die->{pips} = $item[4];
        $return=ORC::DieExpression->new($die);
      }

die_expression_modifier:
    <skip:''> /d|k|r|s|es|e|o/ number <skip:$item[1]>
      {
        my $label_for={
           'd' => 'drop',
           'k' => 'keep',
           'r' => 'reroll',
           's' => 'success',
          'es' => 'explodingsuccess',
           'e' => 'explode',
           'o' => 'open',
        };
        $return={ $label_for->{$item[2]} => $item[3] };
      }

number:
    integer_sign integer label(?)
    {
      my $i=$item{integer};
      my $label=$item[-1] ? $item[-1]->[0] : undef;
      $i=0-$i if (defined $i and defined $item{integer_sign} and $item{integer_sign} eq '-');
      $return=ORC::Number->new(value => $i, label => $label);
    }

integer_sign: /[\-\+]?/

integer:
    /\d+/

label:
    /[ \t]*/ escaped_string["`"] { $item[2] }

escaped_string: <rulevar: ($delim_open, $delim_close)>
  | {
      if (defined $arg[0]) {
        $delim_open=$arg[0];
        if (defined $arg[1]) {
          $delim_close=$arg[1];
        }
        else {
          $delim_close=$delimiter_map->{$delim_open} || $delim_open;
        }
      }
      else {
        $delim_open=qr{\a};
        $delim_close=qr{\Z};
      }
    } <reject>
  | <skip:''> /$delim_open/ escaped_char[$delim_close](s?) /$delim_close/ <skip:$item[1]> { $return=join('', @{$item[3]}) }

escaped_char: <rulevar: $delim=defined $arg[0] ? $arg[0] : '\Z'>
  | /(?!${delim})[^\\]/ { $item[1] }
  | /\\/ /[aefnrt]/ { $return=$escape_map->{$item[2]} || $item[2]; }
  | /\\/ /[0-7]{3}/ { $return=chr(oct($item[2])) }
  | /\\o\{/ /[0-7]+/ /\}/ { $return=chr(oct($item[2])) }
  | /\\x/ /[0-9a-f][0-9a-f]/i { $return=chr(hex($item[2])) }
  | /\\x\{/ /[0-9a-f]+/i /\}/ { $return=chr(hex($item[2])) }
  | /\\c/ /[a-z]/i { $return=chr(ord(uc $item[2])-64) }

