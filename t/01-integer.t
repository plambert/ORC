use Modern::Perl qw/2012/;
use Test::More;
use Carp::Always;
use Test::LongString;
use ORC;

my $expressions=[
  '9;',
  '+6;'
];

plan tests=>scalar @$expressions;

$::RD_TRACE=$ENV{ORC_TEST_TRACE} ? 1 : 0;

our $orc=ORC->new;

for my $plan (@$expressions) {
  $plan={expression=>$plan} unless (ref $plan);
  my $expression=$plan->{expression};
  my $result=$orc->parse($expression);
  diag Dumper($result); use Data::Dumper;
  ok($result);
}

done_testing;

