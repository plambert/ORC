use warnings;
use strict;
use Test::More;

our $dsl;

# test loading our module at compile-time
BEGIN { use_ok('DSL'); }

my @dsl_parse_tests=(
  "print 7;",
  "print 7;\n",
  "c=9+3;\n",
  "c=9+3; print c;",
  "c=9+3;\nprint c;\n",
  "c=9+3;y=c*2+1;print y;",
  "a=1d6;",
  "print 1d6;",
  "print 3d6;",
  "print 4d6d1;",
  "TODO[[see if this passes]] print 1;\n\nprint 2;\n\n\n",
);

my @dsl_value_tests=(
  "print 1;\n"                  => 1,
  "print 7;"                    => 7,
  "print 1+1;"                  => 2,
  "print 1+2*3;"                 => 7,
  "a=7;print a;"                => 7,
  "print 3d6;"                  => 9,
  "print 3d6;"                  => 9,
  "print 1d6+1d6;"              => 8,
);

# plan tests => $plans + @dsl_parse_tests + @dsl_parse_tests_TODO;

subtest 'Basic module loading' => sub {
  plan tests => 2;
  can_ok('DSL', 'new');
  $dsl=DSL->new;
  isa_ok($dsl, "DSL");
};

subtest 'Parsing tests' => sub {
  plan tests => scalar(@dsl_parse_tests);
  dsl_parse_test(@dsl_parse_tests);
};

dsl_value_test(@dsl_value_tests);

sub dsl_parse_test {
  my ($string, $compressed_string, $result, $compressed_result);
  while(@_) {
    local $TODO;
    $string=shift;
    if ($string =~ s{^TODO\[\[(.*?)\]\]\s*}{}) {
      $TODO = $1;
    }
    else {
      undef $TODO;
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
    ok($compressed_string eq $compressed_result, "parse: $string") or diag("returned: ", $result);
  }
}

sub dsl_value_test {
  my $index=1;
  while(@_ > 1) {
    my ($string, $expected) = (shift, shift);
    subtest "Value test #" . $index => sub {
      local $TODO;
      plan tests => 3;
      if ($string =~ s{^TODO\[\[(.*?)\]\]\s*}{}) {
        $TODO = $1;
      }
      else {
        undef $TODO;
      }
      srand(42);
      ok(my $parsed=$dsl->parse($string), "Random test #" . $index. " parses correctly");
      isa_ok($parsed, "DSL::Script", "Parsed script is a DSL script");
      is(0+$parsed->do, $expected, "Random test #" . $index . " returns " . $expected);
    };
    $index++;
  }
}

done_testing;
