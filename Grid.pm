package Grid;

use strict;
use warnings;

sub new {
  my $class = shift;

  my @self;
  push @self, undef for (0 .. 9); # Keep 0 open

  return bless \@self, $class;
}

sub show {
  my $self = shift;

  for my $i (1 .. 9) {
    my $element = $self->[$i] ? $self->[$i] : ' ';
    print "$element";
    if (($i % 3) == 0) {
      print "\n";
      print "-----\n" unless ($i == 9);
    } else {
      print "|";
    }
  }
  print "\n";
}

sub set {
  my ($self, $block, $value) = @_;

  die "Invalid play. Space already occupied\n" if $self->[$block];
  $self->[$block] = $value;
}

sub unset {
  my ($self, $block) = @_;
  $self->[$block] = undef;
}

sub is_winner {
  my ($self, $value) = @_;

  my @winning = ([1,2,3],[4,5,6],[7,8,9],     # Horizontal
                 [1,4,7],[2,5,8],[3,6,9],     # Vertical
                 [1,5,9],[3,5,7]);            # Diagonal

  for my $sequence (@winning) {
    my $first = $sequence->[0];
    my $second = $sequence->[1];
    my $third = $sequence->[2];

    next unless ($self->[$first] && $self->[$second] && $self->[$third]);
    next unless ($self->[$first] eq $value);

    if (($self->[$first] eq $self->[$second]) && ($self->[$first] eq $self->[$third])) {
      return 1;  # Winner
    }
  }
  return 0;
}

sub is_cats_game {
  my $self = shift;

  for my $i (1 .. 9) {
    return 0 if !$self->[$i];  # Board not full
  }
  return 1;  # Tie
}

sub open {
  my $self = shift;
  my @open;

  for my $i (1 .. 9) {
    push @open, $i unless $self->[$i];
  }
  return @open;
}

1;

