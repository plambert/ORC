use Modern::Perl qw/2012/;

package ORC::RandomNumberGenerator;

use Moose;
use Carp;

our $singleton;

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
  my $random_float;
  my $result;
  croak __PACKAGE__ . " queue is empty" if (defined $self->queue and !@{$self->queue});
  if (1 == @_ and ref $_[0] eq 'ARRAY') {
    @_=@{shift @_};
  }
  if (1 == @_) {
    $min=1;
    $max=shift @_;
  }
  elsif (2 == @_) {
    $min=shift @_ // 'undef';
    $max=shift @_ // 'undef';
  }
  elsif (2 < @_) {
    $min=1;
    $max=1;
    while(@_) {
      my $pip=shift;
      $min=$pip if ($pip < $min);
      $max=$pip if ($pip > $max);
    }
  }
  if ($min !~ /^\d+$/ or $max !~ /^\d+$/ or $min < 1 or $max < 1 or $min >= $max) {
    croak sprintf "%s -> %s: invalid range for generated random number", $min // 'undef', $max // 'undef';
  }
  if (defined $self->queue) {
    $result = $self->mock_next($max-$min);
  }
  else {
    $result=int(rand() * ($max-$min) + $min);
  }
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
  my $new=$_[0];
  if (defined $new and 'ARRAY' eq ref $new) {
    $singleton=$class->new(queue => $new);
  }
  elsif (defined $new and ref $new) {
    $singleton=$new;
  }
  elsif (@_) {
    $singleton=$class->new(queue => [@_]);
  }
  elsif (!defined $singleton) {
    $singleton=$class->new;
  }
  return $singleton;
}

sub mock_next {
  my $self=shift;
  my $pips=shift;
  my $q=$self->queue;
  my $next;
  if ($q->[0] and ref $q->[0] eq 'CODE') {
    return $q->[0]->(@_);
  }
  $next=shift @$q;
  if (defined($next) and !ref $next and $next =~ m{^(\d+)/(\d+)$}) {
    return 1.0*$1/$2;
  }
  elsif (defined $next and !ref $next) {
    elsif ($next >= 0.0 and $next < 1.0) {
      return 1.0 * $next;
    }
    else {
      croak "${next}: invalid entry in queue, no explicit or implied divisor";
    }
  }
  else {
    croak "${next}: invalid entry in queue";
  }
}

__PACKAGE__->meta->make_immutable;

1;
