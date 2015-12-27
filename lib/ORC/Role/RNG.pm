package ORC::Role::RNG;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose::Role;
use Carp;

requires 'next';

has 'history' => (
  'is' => 'ro',
  'isa' => 'ArrayRef',
  'required' => 0,
  'default' => sub { [] },
);

around 'next' => sub {
  my $orig=shift;
  my $self=shift;
  my @args=@_;
  my $min;
  my $max;
  my $result;
  @args=@{$args[0]} if (1==@args and ref $args[0] eq 'ARRAY');
  if (1 == @args) {
    $min=1;
    $max=shift @args;
  }
  elsif (2 == @args) {
    $min=shift @args;
    $max=shift @args;
  }
  elsif (2 < @args) {
    $min=1;
    $max=1;
    while(@args) {
      my $pip=shift @args;
      $min=$pip if ($pip < $min);
      $max=$pip if ($pip > $max);
    }
  }
  if ($min !~ m{^\d+$} or $max !~ m{^\d+$} or $min < 1 or $max < 1 or $min >= $max) {
    croak sprintf "%s -> %s: invalid range for generated random number", $min // 'undef', $max // 'undef';
  }
  $result=$orig->($self, $min, $max);
  return $result unless (defined $result);
  if (ref $result) {
    push @{$self->history}, $result;
    return $result->{result} if defined($result->{result});
  }
  else {
    push @{$self->history}, {result => $result, min => $min, max => $max};    
    return $result;
  }
  return;
};

sub last {
  my $self=shift;
  if (@{$self->history}) {
    return $self->history->[-1];
  }
  else {
    return;
  }
}

sub undo {
  my $self=shift;
  if (@{$self->history}) {
    return pop @{$self->history};
  }
  else {
    return;
  }
}

1;
