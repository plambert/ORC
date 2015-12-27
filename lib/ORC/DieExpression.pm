#!/usr/bin/perl -w

# using dice expressions from http://lmwcs.com/rptools/wiki/Dice_Expressions
# a die has:
#    face_value: originally rolled value
#    value: the value to use after modifications
#    ignore: undef for dice to use, otherwise the reason it was dropped
#    index: order in which it was rolled (starting with 1, not 0)

package ORC::DieExpression;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use List::Util qw/min max/;
use overload
  '""' => sub { $_[0]->prettyprint },
  'eq' => sub { $_[0]->prettyprint eq $_[1] };

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

has 'dice' => (
  is => 'rw',
  isa => 'ArrayRef[HashRef]',
  traits => ['Array'],
  builder => '_build_dice',
  lazy => 1,
  handles => {
    _count => 'count',
  }
);

has '_total' => (
  is => 'rw',
  isa => 'Int',
  default => 0,
);

has [qw{drop keep reroll success explodingsuccess explode open}] => (
  is => 'ro',
  isa => 'Int|ORC::Number|Undef',
  default => undef,
  required => 0,
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
  if ($args->{dice}) {
    my $idx=0;
    my @dice;
    for (@{$args->{dice}}) {
      $idx += 1;
      if (ref $_) {
        push @dice, $_;
      }
      else {
        push @dice, {ignore => undef, face_value=>$_, value=>$_, index => $idx };
      }
    }
    $args->{dice}=\@dice;
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
  my $rng=ORC->rng;
  return $rng->next(@_);
}

sub do {
  my $self=shift;
  return $self->roll;
}

sub final_dice {
  my $self=shift;
  my $dice=$self->dice;
  for my $die (0..$#$dice) {
    unless (ref $dice->[$die]) {
      $dice->[$die]={ignore => undef, face_value => $dice->[$die], value => $dice->[$die], index => $die+1}
    }
    $dice->[$die]->{value} = $dice->[$die]->{face_value} unless (defined $dice->[$die]->{value});
  }
  return @$dice;
}

sub _add_die {
  my $self=shift;
  my $count=$self->_count;
  for my $die (@_) {
    if (!ref $die) {
      $count += 1;
      push @{$self->dice}, { ignore => undef, face_value => $die, value => $die, index => $count };
    }
  }
}

sub _sort_dice_by_face_value {
  my $self=shift;
  my @dice=sort { $a->{face_value} <=> $b->{face_value} } ($self->final_dice);
  return @dice;
}

# drop the lowest N dice
sub _drop_dice {
  my $self=shift @_;
  my $to_drop=shift(@_) // $self->drop;
  return $self unless ($to_drop);
  my @dice=grep { !$_->{ignore} } ($self->_sort_dice_by_face_value);
  my $die_index=0;
  while($die_index < $to_drop) {
    $dice[$die_index]->{ignore}='drop';
    $die_index += 1;
  }
  return $self;
}

# keep the highest N dice
# which is to say, drop the COUNT-N lowest dice
sub _keep_dice {
  my $self=shift @_;
  my $to_keep=$self->keep;
  return $self unless ($to_keep);
  my $count=scalar @{$self->final_dice};
  return $self->_drop_dice($count-$to_keep);
}

sub total {
  my $self=shift;
  my $total=$self->_total;
  unless ($total) {
    my @dice=$self->final_dice;
    $total=0;
    $total += $_->{value} for (grep { !$_->{ignore} } @dice);
    $self->_total($total);
  }
  return $total;
}

sub roll {
  my $self=shift;
  #$self->_roll_dice unless ($self->dice and @{$self->dice});
  $self->_drop_dice if ($self->drop);
  $self->_keep_dice if ($self->keep);
  $self->_reroll_dice if ($self->reroll);
  $self->_success_dice if ($self->success);
  $self->_exploding_success_dice if ($self->explodingsuccess);
  $self->_explode_dice if ($self->explode);
  $self->_open_dice if ($self->open);

  return $self->total;
}

sub _build_dice {
  my $self=shift;
  my $dice=[];
  for (1..$self->count) {
    my $single_die=$self->random(1, $self->pips);
    #int(rand($self->pips)+1);
    push @$dice, { ignore => undef, face_value => $single_die, value => $single_die };
  }
  return $dice;
}

__PACKAGE__->meta->make_immutable;

1;
