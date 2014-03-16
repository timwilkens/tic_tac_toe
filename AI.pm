package AI;

use strict;
use warnings;
use Grid;
use Data::Dumper;

sub new {
  my ($class, $value) = @_;
  my %self;
  $self{value} = $value;
  $self{opponent} = ($value eq 'X') ? 'O' : 'X';

  return bless \%self, $class;
}

sub play {
  my ($self, $grid, $value) = @_;


  if (scalar($grid->open()) == 9) {
    my @plays = (1,3,5,7,9); # Only play center or corners on opening
    return $plays[int(rand(4))];
  }

  # Play one move win.
  if (my $play = $self->need_to_play($grid, $self->{value})) { return $play; }

  # Block opponent win.
  if (my $play = $self->need_to_play($grid, $self->{opponent})) { return $play; }

  my ($play, $score) = $self->ABminimax($grid, $value, -2, 2); # Alpha and Beta initialized
  return $play;
}

sub ABminimax {
  my ($self, $grid, $value, $alpha, $beta) = @_;
  my $player_value = $self->{value};
  my $opponent_value = $self->{opponent};;
  my $next_play = ($value eq 'X') ? 'O' : 'X';

  if ($grid->is_winner($player_value)) {
    return (undef, 1);
  } elsif ($grid->is_winner($opponent_value)) {
    return (undef, -1);
  } elsif ($grid->is_cats_game) {
    return (undef, 0);
  }

  my @open = $grid->open();
  my $best_score;
  my $best_move;

  if ($value eq $player_value) {  # Initialize current value based on
    $best_score = $alpha;         # Max player level or Min player level
  } else {
    $best_score = $beta;
  }

  for my $block (@open) {

    $grid->set($block, $value);  # Play.
    my (undef, $play_score) = $self->ABminimax($grid, $next_play, $alpha, $beta);
    $grid->unset($block);  # Undo.

    if (($value eq $player_value) && ($play_score > $best_score)) {
      $best_score = $play_score;
      $alpha = $play_score;
      $best_move = $block;
    } elsif (($value eq $opponent_value) && ($play_score < $best_score)) {
      $best_score = $play_score;
      $beta = $play_score;
      $best_move = $block;
    }
    if ($alpha >= $beta) {  # Prune.
      return ($best_move, $best_score);
    }
  }
  return ($best_move, $best_score);
}

sub need_to_play {
  my ($self, $grid, $value) = @_;


  my @winning = ([1,2,3],[4,5,6],[7,8,9],     # Horizontal
                 [1,4,7],[2,5,8],[3,6,9],     # Vertical
                 [1,5,9],[3,5,7]);            # Diagonal


  for my $sequence (@winning) {
    my $first = $sequence->[0];
    my $second = $sequence->[1];
    my $third = $sequence->[2];

    my @matches;
    my @not_set;
 
    for my $block (($first, $second, $third)) {
      if ($grid->[$block]) {
        if ($grid->[$block] eq $value) {
          push @matches, $block;
        }
      } else {
        push @not_set, $block;
      }

      if ((scalar(@matches) == 2) && scalar(@not_set)) {
        return $not_set[0];
      }
    }
  }
}

1;

