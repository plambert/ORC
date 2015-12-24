use Modern::Perl qw/2012/;
use Test::More;
use Carp::Always;
use Test::LongString;
use ORC;
use JSON;
use Path::Tiny;

$::RD_TRACE=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)trace($|\s|,)}i);
$::RD_HINT=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)hint($|\s|,)}i);

our $orc=ORC->new;
my $json=JSON->new->allow_blessed->convert_blessed->canonical->allow_nonref;
my $expressions=$json->decode(path("t/expressions.json")->slurp_utf8);

plan tests => scalar @$expressions;

for my $subtest (@$expressions) {
  my ($name, $expression, $expected, $debug)=@$subtest;
  diag sprintf "test: %s\n", $json->encode($subtest) if ($debug);
  my $result=$orc->parse($expression);
  diag sprintf "original result: %s\n", $json->encode($result) if ($debug);
  if ($result and $result->can('do')) {
    $result=$result->do;
  }
  my $ok=is($result, $expected, $name);
  if (!$ok or $debug) {
    diag sprintf "%s: %s\n  expect: %d\n  result: %s\n",
      $name, $json->encode($expression), $json->encode($expected), $json->encode($result);
  }
}

done_testing;

