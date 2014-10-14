package DSL;

our $SELF;
sub new { return $SELF }

sub action_default {
  print STDERR "===action_default\n", Dumper(\@_);
  my $self=shift;
  if (@_ > 1) {
    return [ @_ ];
  }
  else {
    return $_[0];
  }
}

# assignment

sub assignment {
  print STDERR "===assignment\n", Dumper(\@_);
  my ($self, $lhs, $rhs) = @_;
  return [ 'ASSIGN', $lhs->[2], $rhs->[2] ];
}

# print_cmd

sub print_cmd {
  print STDERR "===print_cmd\n", Dumper(\@_);
  my ($self, undef, $expr) = @_;
  return [ 'PRINT', $expr->[2] ];
}

# paren

sub paren {
  print STDERR "===paren\n", Dumper(\@_);
  my ($self, undef, $expr, undef) = @_;
  return $expr->[2];
}

# op

sub op {
  print STDERR "===op\n", Dumper(\@_);
  my ($self, $lhs, $op, $rhs) = @_;
  return [ $op->[2], $lhs->[2], $rhs->[2] ];
}

# dice_simple

sub dice_simple {
  my ($self, $count, $sides) = @_;
  return [ 'DICE', $count->[2], $sides->[2] ];
}

# dice_drop

sub dice_drop {
  my ($self, $count, $sides, $drop) = @_;
  return [ 'DICE', $count->[2], $sides->[2], 'DROP', $drop->[2] ];
}

# dice_keep

sub dice_keep {
  my ($self, $count, $sides, $keep) = @_;
  return [ 'DICE', $count->[2], $sides->[2], 'KEEP', $keep->[2] ];
}

# dice_reroll

sub dice_reroll {
  my ($self, $count, $sides, $reroll) = @_;
  return [ 'DICE', $count->[2], $sides->[2], 'REROLL', $reroll->[2] ];
}

# dice_success

sub dice_success {
  my ($self, $count, $sides, $success) = @_;
  return [ 'DICE', $count->[2], $sides->[2], 'SUCCESS', $success->[2] ];
}

# dice_explode_success

sub dice_explode_success {
  my ($self, $count, $sides, $success) = @_;
  return [ 'DICE', $count->[2], $sides->[2], 'EXPLODE_SUCCESS', $success->[2] ];
}

# dice_explode

sub dice_explode {
  my ($self, $count, $sides) = @_;
  return [ 'DICE', $count->[2], $sides->[2], 'EXPLODE' ];
}

# dice_open

sub dice_open {
  my ($self, $count, $sides) = @_;
  return [ 'DICE', $count->[2], $sides->[2], 'OPEN' ];
}

sub dice_expression {
  my ($self, $expr) = @_;
  my $dicetype={ 'd' => 'DROP', 'k' => 'KEEP', 'r' => 'REROLL', 's' => 'SUCCESS', 'es' => 'EXPLODE_SUCCESS', 'e' => 'EXPLODE', 'o' => 'OPEN' };
  $expr=$expr->[2];
  return undef unless ($expr =~ s{^(\d+)d(\d+)}{});
  my ($count, $sides) = ($1, $2);
  if ($expr=~m{^(d|k|r|s|es)(\d+)}) {
    return [ 'DICE', $count, $sides, $dicetype->{$1}, $2 ];
  }
  elsif ($expr =~ m{^([eo])$}) {
    return [ 'DICE', $count, $sides, $dicetype->{$1} ];
  }
  else {
    return undef;
  }
}
1;
