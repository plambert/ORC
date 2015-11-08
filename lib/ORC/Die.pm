#!/usr/bin/perl -w

package ORC::Die;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use overload '""' => sub { $_[0]->prettyprint };

has 'count' => (
  is => 'rw',
  default => 1,
);

has 'pips' => (
  is => 'rw',
  required => 1,
);

has 'previous' => (
  is => 'rw',
);

has 'raw_dice' => (
  is => 'rw',
);

has 'total' => (
  is => 'rw',
);

has 'final_dice' => (
  is => 'rw',
);

has 'removed_dice' => (
  is => 'rw',
  default => sub { return {}; },
);

has 'drop' => (
  is => 'ro',
);

has 'keep' => (
  is => 'ro',
);

has 'reroll' => (
  is => 'ro',
);

has 'success' => (
  is => 'ro',
);

has 'explodingsuccess' => (
  is => 'ro',
);

has 'explode' => (
  is => 'ro',
);

has 'open' => (
  is => 'ro',
);

sub prettyprint {
  my $self=shift;
  my $string=sprintf("%d%s%d", $self->count, 'd', $self->pips);
  $string .= 'd'  . $self->drop             if ($self->drop);
  $string .= 'k'  . $self->keep             if ($self->keep);
  $string .= 'r'  . $self->reroll           if ($self->reroll);
  $string .= 's'  . $self->success          if ($self->success);
  $string .= 'es' . $self->explodingsuccess if ($self->explodingsuccess);
  $string .= 'e'                            if ($self->explode);
  $string .= 'o'                            if ($self->open);
  return $string;
}

sub do {
  my $self=shift;
  return $self->roll;
}

sub roll {
  my $self=shift;
  my $total=0;
  $self->rollRaw unless ($self->raw_dice and @{$self->raw_dice});
  $self->final_dice($self->raw_dice);
  $self->dropDice if ($self->drop);
  $self->keepDice if ($self->keep);
  $self->rerollDice if ($self->reroll);
  $self->successDice if ($self->success);
  $self->explodingsuccessDice if ($self->explodingsuccess);
  $self->explodeDice if ($self->explode);
  $self->openDice if ($self->open);

  $total += $_ for (@{$self->final_dice});
  $self->total($total);

  return $total;
}

sub rollRaw {
  my $self=shift;
  my @raw_dice;
  for (1..$self->count) {
    my $singleDie=int(rand($self->pips)+1);
    push @raw_dice, $singleDie;
  }
  $self->raw_dice(\@raw_dice)
}

sub dropDice {
  my $self = shift;
  $self->rollRaw unless ($self->raw_dice and @{$self->raw_dice});
  my @rolled_dice=@{$self->raw_dice};
  # print STDERR Data::Dumper::Dumper($self->drop); use Data::Dumper;
  my $drop=0+$self->drop->value;
  if (defined $drop and $drop > 0) {
  
    my @sorted_dice=sort { $a <=> $b } (@rolled_dice);
    my @values_to_remove=@sorted_dice[0..($drop-1)];
    # print STDERR "rolled_dice: ", join(',', @rolled_dice), "\n";
    # print STDERR "sorted dice: ", join(',', @sorted_dice), "\n";
    for my $value (@values_to_remove) {
      my $idx=0;
      $idx++ until $rolled_dice[$idx] == $value;
      splice(@rolled_dice, $idx, 1);
    }
    # print STDERR "final dice: ", join(',', @rolled_dice), "\n";
    $self->removed_dice->{dropped}=\@values_to_remove;
  }
  $self->final_dice(\@rolled_dice);
  return $self->final_dice;
}

__PACKAGE__->meta->make_immutable;

1;
