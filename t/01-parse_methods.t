use Modern::Perl qw/2012/;
use Test::More;
use Carp::Always;
use Test::LongString;
use ORC;
use Data::Dumper;

my $tests={
  '01-escaped_char' => [
    {
      name=>'simple character',
      text=>'h',
      expect=>'h',
    },
    {
      name=>'escaped linefeed',
      text=>'\n',
      expect=>"\n",
    },
    {
      name=>'escaped hex character',
      text=>'\x27',
      expect=>"\x27",
    },
    {
      name=>'escaped tab',
      text=>'\t',
      expect=>"\t",
    },
    {
      name=>'control character',
      text=>'\cA',
      expect=>"\cA",
    },
  ],
  '02-escaped_string' => [
    {
      name=>'simple quoted string',
      text=>'"hello"',
      args=>['"'],
      expect=>'hello',
    },
    {
      name=>'simple label',
      text=>'`hello`',
      args=>['`','`'],
      expect=>'hello',
    },
    {
      name=>'simple label',
      text=>'`hello`',
      args=>['`','`'],
      expect=>'hello',
    },
  ],
  '03-label' => [
    {
      name=>'simple label',
      text=>'`hello`',
      expect=>'hello',
    },
    {
      name=>'more complex label',
      text=>'`hello this is \x27a\x27 complex label`',
      expect=>"hello this is \x27a\x27 complex label",
    }
  ],
  '04-number' => [
    {
      name=>'simple integer',
      text=>'13',
      expect=>"13",
    },
    {
      name=>'positive integer without whitespace',
      text=>'+32',
      expect=>"32",
    },
    {
      name=>'positive integer with whitespace',
      text=>'+ 23',
      expect=>"23",
    },
    {
      name=>'negative integer without whitespace',
      text=>'-13',
      expect=>"-13",
    },
    {
      name=>'negative integer with whitespace',
      text=>'- 13',
      expect=>"-13",
    },
    {
      name=>'simple integer with label',
      text=>'13 `morale`',
      stringify=>1,
      expect=>'13 `morale`',
    },
  ],
  '05-die_expression' => [
    {
      name=>'simple die expression',
      text=>'1d6',
      expect=>'1d6',
    },
  ],
};

plan tests=>scalar keys %$tests;

$::RD_TRACE=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)trace($|\s|,)}i);
$::RD_HINT=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)hint($|\s|,)}i);

our $orc=ORC->new;

sub argstring {
  my $ref=shift;
  return '' unless (@$ref);
  return sprintf "[%s]", join(',', map { "\x27$_\x27" } (@$ref));
}

for my $method_key (sort keys %$tests) {
  my $method=$method_key;
  my $tests_for_method=$tests->{$method_key};
  $method=~s{^\d+-}{};
  subtest "parse method ${method}" => sub {
    plan tests => scalar @$tests_for_method;
    for my $test (@$tests_for_method) {
      $test->{args} //= [];
      subtest $test->{name} => sub {
        plan tests => $test->{expect} ? 2 : 1;
        my $result=$orc->parse({method=>$method}, $test->{text}, @{$test->{args}});
        $result="$result" if (defined $result and $test->{stringify});
        ok($result, "parsed");
        if (!$result or $test->{debug}) {
          diag sprintf "parse(\x27%s\x27,\x27%s%s\x27)%s\n%s",
            $test->{text}, $method, argstring($test->{args}), $test->{expect} ? sprintf(" => \x27%s\x27",$test->{expect}) : "", Dumper($result);    
        }
        unless (is($result, $test->{expect}, "result") or !$test->{debug}) {
          diag sprintf "parse(\x27%s\x27,\x27%s%s\x27) => \x27%s\x27\n%s",
            $test->{text}, $method, argstring($test->{args}), $test->{expect}, Dumper($result);
        }
      };
    };
  };
}

done_testing;

