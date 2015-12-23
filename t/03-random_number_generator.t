use Modern::Perl qw/2012/;
use Test::More;
use Carp;
use Carp::Always;
use Test::LongString;
use JSON;
use ORC::RandomNumberGenerator;
my $debug;
my @r;

$debug=shift @ARGV if ($ARGV[0] and $ARGV[0] =~ m{^(-d|--debug)$}i);

my $tests={
  '01-ranges' => [
    { range => [1,100] },
    { range => [1,10000], count => 10 },
  ],
  '02-specific queues' => [
    { queue => [1,2,3,4,5,6], pips => 6 },
  ],
};

plan tests => scalar keys %$tests;

my $json=JSON->new->allow_nonref->canonical->utf8->allow_blessed->convert_blessed;

# run a test given:
#   a queue (either directly, as fractions, as a range, etc)
#   an expectation (either implied or directly)
#   an optional random number seed
#   an optional flag to use the given seed to generate the list but skip the test

sub test_rng_with_queue {
  my $opts=shift;
  my $expect;
  my $name;
  my $queue;
  my $result=[];
  my $pips;
  my $ok;
  my $max;

  $opts=$opts->() while (ref $opts eq 'CODE');
  $opts={queue => $opts} if (ref $opts eq 'ARRAY');

  for my $k (keys %$opts) {
    while (ref $opts->{$k} eq 'CODE') {
      $opts->{$k} = $opts->{$k}->();
    }
  }

  if ($opts->{name}) {
    $name=delete $opts->{name};
  }
  else {
    $name=sprintf "Test->%s", $json->encode($opts);
  }

  $max=delete $opts->{max} if (exists $opts->{max});

  if ($opts->{queue}) {
    $queue=delete $opts->{queue};
    unless (defined $max) {
      $max=$queue->[0];
      for my $v (@$queue) {
        $max=$v if (defined $v and $v =~ m{^[\d\.]+$} and $v>$max);
      }
    }
  }
  elsif (my $range=delete $opts->{range}) {
    my ($range_min, $range_max) = @$range;
    $queue=[ $range_min..$range_max ];
    $expect=[ $range_min..$range_max ];
    $max //= $range_max;
  }

  if ($opts->{pips}) {
    $pips=delete $opts->{pips};
  }
  elsif ($max) {
    $pips=$max;
  }

  if (!$pips or (!ref $pips and $pips < 1) or (ref $pips eq 'ARRAY' and !@$pips)) {
    croak sprintf "pips=%s: must have 1 or more pips", $json->encode($pips);
  }

  # handle queue entries that look like '1/6' fractions
  $queue=[ map { m{^(\d+)/(\d+)$} ? 1.0*$1/$2 : 1.0*$_/$pips } @$queue ];
  
  if ($opts->{expect}) {
    $expect=delete $opts->{expect};
  }

  if ($opts->{count} and $opts->{count} > @$expect) {
    splice(@$expect, $opts->{count});
  }

  if (!ref $pips) {
    $pips=[ map { $pips } (0..$#{$expect})];
  }

  push @$pips, $max while (@$pips<@$expect);

  #diag "queue: " . $json->encode($queue);

  my $rng=ORC::RandomNumberGenerator->new({queue => $queue});

  push @$result, $rng->next($pips->[$_]) for (0..$#{$expect});

  if ($opts->{skip}) {
    $ok=pass("SKIPPED: " . $name);
  }
  else {
    $ok=is_deeply($result, $expect, $name);
  }

  diag sprintf "test: %s\npips: %s\nresult: %s\nexpect: %s\n", 
        map { $json->encode($_) } ($name, $pips, $result, $expect)
        unless ($ok);
  return $ok;
}

for my $subtest (sort keys %$tests) {
  my $subtest_name=$subtest;
  $subtest_name=~s{^\d+-}{};
  my $subtests=$tests->{$subtest};
  subtest $subtest_name => sub {
    for my $test (@$subtests) {
      test_rng_with_queue($test);
    }
  };
}
