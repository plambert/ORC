# random number generator superclass

use Modern::Perl qw/2012/;

package ORC::RNG;

use Moose;
use Carp;
use namespace::sweep;

our $singleton;

my $class_for_type={
  'mock' => 'ORC::RNG::Mock',
  'random' => 'ORC::RNG::Random',
};

sub singleton {
  my $class=shift;
  my $opt;
  if (!@_) {
    $singleton=ORC::RNG::Random->new unless (defined $singleton);
    return $singleton;
  }
  $opt=shift;
  if (!defined $opt or ref $opt or !exists $class_for_type->{$opt}) {
    croak "expected a simple scalar parameter, either 'mock' or 'random'";    
  }
  $singleton=$class_for_type->{$opt}->new(@_);
  return $singleton;
}

sub random {
  my $class=shift;
  return $class->singleton('random', @_);
}

sub mock {
  my $class=shift;
  return $class->singleton('mock', @_);
}

__PACKAGE__->meta->make_immutable;

1;
