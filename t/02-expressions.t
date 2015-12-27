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
my $limit=shift(@ARGV) // 0;

plan tests => $limit || scalar @$expressions;

for my $subtest (@$expressions) {
  my @original_test=@$subtest;
  my $name=shift @$subtest;
  my $expression=shift @$subtest;
  my $expected=shift @$subtest;
  my ($debug, @queue);
  @$subtest=grep { defined $_ } (@$subtest);
  while (@$subtest) {
    if ($subtest->[0] eq 'DEBUG') {
      $debug=shift @$subtest;
    }
    elsif ($subtest->[0] =~ m{^\d+$}) {
      push @queue, shift @$subtest;
    }
    else {
      die "$0: unknown entries: " . $json->encode($subtest) . "\n";
    }
  }
  diag sprintf "test: %s\n", $json->encode(\@original_test) if ($debug);
  ORC->mock_random_numbers(\@queue) if (@queue);
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
  $limit -= 1;
  last if ($limit == 0);
}

done_testing;

