use Modern::Perl qw/2012/;
use Test::More;
use Carp::Always;
use Test::LongString;
use ORC;
use JSON;

my $expressions={
  'addition' => ['9+2;' => 11],
  'multiplication' => ['4*3;' => 12],
  'division' => ['6/2;' => 3],
};

plan tests => 3;

our $orc=ORC->new;
my $json=JSON->new->allow_blessed->convert_blessed->canonical->allow_nonref;

for my $subtest_name (qw/addition multiplication division/) {
  my ($subtest_expression, $expected_result)=@{$expressions->{$subtest_name}};
  diag sprintf "%s should be %d", $subtest_expression, $expected_result;
  my $result=$orc->parse($subtest_expression);
  diag "JSON: " . $json->encode($result);
  diag $result->dump;
  is($result->do, $expected_result, $subtest_name);
}

done_testing;

