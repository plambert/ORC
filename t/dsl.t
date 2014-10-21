use warnings;
use strict;
use Test::More;

# my $plans=3;

BEGIN { use_ok('DSL'); }

my @dsl_parse_tests=(
  "print 7;",
  "print 7;\n",
  "c=9+3;\n",
  "c=9+3; print c;",
  "c=9+3;\nprint c;\n",
  "c=9+3;y=c*2+1;print y;",
);
my @dsl_parse_tests_TODO=(
  "a=1d6;",
  "print 1d6;",
);

# plan tests => $plans + @dsl_parse_tests + @dsl_parse_tests_TODO;

can_ok('DSL', 'new');

our $dsl=DSL->new;

isa_ok($dsl, "DSL");

dsl_parse_test(@dsl_parse_tests);

TODO: {
  local $TODO='not yet implemented';
  dsl_parse_test(@dsl_parse_tests_TODO);
}

sub dsl_parse_test {
  my ($string, $compressed_string, $result, $compressed_result, $todo);
  while(@_) {
    if (ref $_[0]) {
      $todo=1;
      $string=shift->[0];
    }
    else {
      $todo=0;
      $string=shift;
    }
    
    $compressed_string=$string;
    $compressed_string=~s{\s+}{}g;
    $result=$dsl->parse($string);
    $result='UNDEF' unless (defined($result));
    if (ref $result and $result->can('prettyprint')) {
      $result=$result->prettyprint;
    }
    $compressed_result=$result;
    $compressed_result =~ s{\s+}{}g;
    $string=~s{\n}{\\n}g;
    $string=~s{\t}{\\t}g;
    if ($todo) {
      TODO: {
        ok($compressed_string eq $compressed_result, "parse: $string") or diag("returned: ", $result);
      }
    }
    else {
      ok($compressed_string eq $compressed_result, "parse: $string") or diag("returned: ", $result);
    }
  }
}

done_testing;
