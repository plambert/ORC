use Modern::Perl qw/2012/;
use Test::More;
use Carp::Always;
use Test::LongString;
use ORC;
use JSON;

my $expressions=[
  [ 'addition' => '9 + 2;' => 11 ],
  [ 'multiplication' => '4*3;' => 12 ],
  [ 'division' => '6/2;' => 3 ],
  [ 'subtraction' => '6-2;' => 4 ],
  [ 'complex1' => '1+2*3-4;' => 3 ],
  [ 'bare addition' => '9+2' => 11 ],
  [ 'bare complex1' => '1+2*3+4-4' => 7 ],
  [ 'complex2' => '1+3*5+1*4/2' => 18 ],
  [ 'sequential one-line addition' => '9+2; 1+2' => 3 ],
  [ 'sequential multi-line addition' => "9+2\n 1+2\n" => 3 ],
  [ 'multi-line addition' => "9+2+\n1+2\n" => 14 ],
  [ 'assignment-1' => 'a=1; a' => 1 ],
  [ 'assignment-2' => "a=\n3" => 3 ],
  [ 'parens-1' => "1+3*(5+1)*2" => 37 ],
];

$::RD_TRACE=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)trace($|\s|,)}i);
$::RD_HINT=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)hint($|\s|,)}i);

plan tests => scalar @$expressions;

our $orc=ORC->new;
my $json=JSON->new->allow_blessed->convert_blessed->canonical->allow_nonref;

for my $subtest (@$expressions) {
  my ($name, $expression, $expected, $debug)=@$subtest;
  my $result=$orc->parse($expression);
  if (defined($result) and $result->can('do')) {
    diag sprintf "original result: %s\n", $json->encode($result) if ($debug);
    $result=$result->do;
  }
  my $ok=is($result, $expected, $name);
  if (!$ok or $debug) {
    diag sprintf "%s: %s\n  expect: %d\n  result: %s\n",
      $name, $json->encode($expression), $json->encode($expected), $json->encode($result);
  }
}

done_testing;

