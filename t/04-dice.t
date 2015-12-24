use Modern::Perl qw/2012/;
use Test::More;
use Carp::Always;
use Test::LongString;
use ORC;
use JSON;

$::RD_TRACE=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)trace($|\s|,)}i);
$::RD_HINT=1 if ($ENV{ORC_TEST} and $ENV{ORC_TEST} =~ m{(^|\s|,)hint($|\s|,)}i);

#our $orc=ORC->new;
my $json=JSON->new->allow_blessed->convert_blessed->canonical->allow_nonref;

#plan tests => 1;

my $rng=ORC::RandomNumberGenerator->singleton;

ok($rng, "Have RNG") or diag Dumper($rng); use Data::Dumper;
my $random=$rng->next(1,6);
ok($random, "Got random number");
diag Dumper($random);
my @random;
push @random, $rng->next(1,6) for (1..10000);
is(scalar(grep { $_ >= 1 and $_ <= 6 and $_==int($_) } (@random) ), 10000, "10000 tries are all in range");

my $loaded_rng=ORC::RandomNumberGenerator->singleton(map { "$_/6" } (1,2,3,4,5,6));
diag Dumper($loaded_rng);
my @loaded_results;
push @loaded_results, $loaded_rng->next(1,6) for (1..6);
is(join(',', @loaded_results), join(',', 1,2,3,4,5,6), "get loaded results back") or diag Dumper(\@loaded_results);

# my $die=ORC::Die->new(count => 1, pips => 6);
# ok($die, "got a die");
# diag Dumper($die); use Data::Dumper;


# ok(my $roll=$die->do, "rolled a result")
#   or diag Dumper($die); use Data::Dumper;

done_testing;

