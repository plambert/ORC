use Modern::Perl qw/2012/;

package ORC::RNG::Mock;

use Moose;
use namespace::sweep;
use Carp;
use ORC::Number;

with "ORC::Role::RNG";

has 'queue' => (
  'is' => 'rw',
  'isa' => 'ArrayRef',
  'required' => 1,
);

has 'default_pips' => (
  'is' => 'rw',
  'isa' => 'Undef|Int',
  'required' => 0,
);

sub next {
  my $self=shift;
  my $min=shift;
  my $max=shift;
  my $queue=$self->queue;
  my $result;
  croak __PACKAGE__ . " queue is empty!" unless (defined $queue->[0]);

  # if it's a code reference, don't take it off the queue
  # until it returns undef, 
  while ('CODE' eq ref $queue->[0]) {
    $result=$queue->[0]->();
    last if (defined $result);
    shift @$queue;
  }

  my $next=shift @$queue;
  if (defined $next and !ref $next) {
    if ($next =~ m{^\s*(\d+)\s*/\s*(\d+)\s*} or $next =~ m{^\s*(\d+)\s*on\s*d(\d+)\s*$}) {
      $result=$1;
    }
    else {
      $result=$next;
    }
  }
  else {
    croak "${next}: not sure what to make of this";
  }
  return {result => $result, min => $min, max => $max};
}

sub add {
  my $self=shift;
  unshift @{$self->queue}, @_;
}

__PACKAGE__->meta->make_immutable;

1;
