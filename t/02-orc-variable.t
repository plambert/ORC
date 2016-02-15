use Modern::Perl qw/2012/;
use Test::More;
use Carp::Always;
use Scalar::Util qw/refaddr/;

our $PKG;

BEGIN {
#  plan tests => 4;
  $PKG="ORC::Variable";
  use_ok $PKG;
}

my $variable=new_ok $PKG, [ name => 'x' ], "Can create a new variable named 'x'";

is $variable->name, "x", "Name is 'x'";

ok !$variable->has_value, "Value is unset";

my $new_variable=ORC::Variable->get( 'x' );

is refaddr $new_variable, refaddr $variable, "New variable is the same object as the old";

#print STDERR "\n\n", ref($new_variable), "\n", ref($variable), "\n\n";

done_testing();
