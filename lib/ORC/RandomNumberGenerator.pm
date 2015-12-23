use Modern::Perl qw/2012/;

package ORC::RandomNumberGenerator;

use Moose;
use Carp;

my $singleton={};

has 'queue' => (
  'is' => 'rw',
  'isa' => 'Undef|ArrayRef',
  'required' => 0,
  'default' => undef,
);

has 'history' => (
  'is' => 'ro',
  'isa' => 'ArrayRef',
  'required' => 0,
  'default' => sub { [] },
);

sub next {
  #print STDERR "NEXT: ", Dumper(\@_), "\n"; use Data::Dumper;
  my $self=shift;
  my $min;
  my $max;
  my $q=$self->queue;
  my $random_float;
  my $result;
  if (1 == @_) {
    $min=1;
    $max=shift @_;
  }
  elsif (2 == @_) {
    $min=shift @_ // 'undef';
    $max=shift @_ // 'undef';
  }
  if ($min !~ /^\d+$/ or $max !~ /^\d+$/ or $min < 1 or $max < 1 or $min >= $max) {
    croak sprintf "%s -> %s: invalid range for generated random number", $min // 'undef', $max // 'undef';
  }
  if (ref $q eq 'ARRAY' and @$q) {
    $random_float = shift @$q;
  }
  else {
    $random_float = rand();
  }
  $result=int($random_float * ($max-$min) + $min);
  push @{$self->history}, {result => $result, min => $min, max => $max};
  return $result;
}

sub last {
  my $self=shift;
  if (@{$self->history}) {
    return $self->history->[-1];
  }
  else {
    return;
  }
}

sub singleton {
  my $class=shift;
  unless (defined $singleton) {
    $singleton=$class->new(@_);
  }
  return $singleton;
}

__PACKAGE__->meta->make_immutable;

1;
