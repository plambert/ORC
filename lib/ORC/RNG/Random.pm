use Modern::Perl qw/2012/;

package ORC::RNG::Random;

use Moose;
use namespace::sweep;
use Carp;

with 'ORC::Role::RNG';

sub next {
  my $self=shift;
  my $min=shift;
  my $max=shift;
  my $result=int(rand() * ($max-$min) + $min);
  return {result => $result, min => $min, max => $max};
}

__PACKAGE__->meta->make_immutable;

1;
