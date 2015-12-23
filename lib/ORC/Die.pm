#!/usr/bin/perl -w

package ORC::Die;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use overload
  '""' => sub { $_[0]->prettyprint },
  'eq' => sub { $_[0]->prettyprint eq $_[1] };

use ORC::RandomNumberGenerator;

with 'ORC::Role::Serializable';

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
  isa => 'ArrayRef[HashRef]',
);

has 'total' => (
  is => 'rw',
);

has 'final_dice' => (
  is => 'rw',
  isa => 'ArrayRef',
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

around BUILDARGS => sub {
  my $orig = shift;
  my $class = shift;
  my $args;
  if ( @_ == 1 and ref $_[0] eq 'HASH' ) {
    $args=shift @_;
  }
  else {
    $args={ @_ };
  }
  if ($args->{raw_dice}) {
    for (@{$args->{raw_dice}}) {
      $_={state => 'kept', face_value=>$_, history=>[$_]} unless (ref $_);
    }
  }
  return $class->$orig($args);
};

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

sub random {
  my $self=shift;
  return ORC::RandomNumberGenerator->singleton->next(@_);
}

sub do {
  my $self=shift;
  return $self->roll;
}

sub roll {
  my $self=shift;
  my $total=0;
  $self->roll_raw unless ($self->raw_dice and @{$self->raw_dice});
  $self->drop_dice if ($self->drop);
  $self->keep_dice if ($self->keep);
  $self->rerollDice if ($self->reroll);
  $self->successDice if ($self->success);
  $self->explodingsuccessDice if ($self->explodingsuccess);
  $self->explodeDice if ($self->explode);
  $self->openDice if ($self->open);

  $total += $_ for (@{$self->final_dice});
  $self->total($total);

  return $total;
}

sub roll_raw {
  my $self=shift;
  my @raw_dice;
  for (1..$self->count) {
    my $single_die=$self->random(1, $self->pips);
    #int(rand($self->pips)+1);
    push @raw_dice, { state => 'kept', face_value => $single_die, history => [ $single_die] };
  }
  $self->raw_dice(\@raw_dice)
}

# drop the lowest N dice
# keeping the original order
sub drop_dice {
  my $self = shift;
  my @rolled_dice=@{$self->raw_dice};
  my @sorted_dice=sort { $a->face_value <=> $b->face_value } (@rolled_dice);
  my @removed_dice;
  my @indices_to_remove;
  # print STDERR Data::Dumper::Dumper($self->drop); use Data::Dumper;
  my $drop=0+$self->drop->value;
  my $indices_for={ map { ( $rolled_dice[$_]->face_value, $_ ) } (0..$#rolled_dice) };

  return unless (defined $drop and $drop > 0);
  
  @sorted_dice=sort { $a <=> $b } (@rolled_dice);

  for my $drop_index (1..$drop) {
    my $face_to_remove=shift @sorted_dice;
    push @removed_dice, $face_to_remove;
    push @indices_to_remove, shift @{$indices_for->{$face_to_remove}};
  }

  for my $index (reverse sort { $a <=> $b } @indices_to_remove) {
    splice @rolled_dice, $index, 1;
  }
  push @{$self->removed_dice->{dropped}}, @removed_dice;
  $self->final_dice(\@rolled_dice);
  return $self;
}

__PACKAGE__->meta->make_immutable;

1;
