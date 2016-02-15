use Modern::Perl qw/2012/;
use Test::More tests => 2;
use Carp::Always;

our $PKG;
our @values_to_test=( qw/ 0 1 2 3 4 5 10 1000 9999 10000/, 1<<16 );

#plan tests => 5+4*$#values_to_test;

BEGIN {
  $PKG="ORC::Number";
	use_ok $PKG;
}

subtest 'Various values' => sub {
  plan tests => scalar(@values_to_test);
  for my $int (@values_to_test) {
    subtest "Value is '" . $int . "'" => sub {
      plan tests => 4;
      my $number=new_ok $PKG, [value => 0], "${PKG}->new(0)";
      is $number->value, 0, "${PKG}->new(0)->value is 0";
      is $number->prettyprint, 0, "${PKG}->new(0)->prettyprint is 0";
      is $number->do, 0, "${PKG}->new(0)->do is 0";
    };
  }
};

done_testing();
