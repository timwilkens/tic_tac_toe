package AI;

use strict;
use warnings;
use Grid;
use Data::Dumper;

sub new {return bless {}, shift;}

sub choose_play {
  my ($self, $grid, $value) = @_;
  $self->{value} = $value;
  my $next_play = ($value eq 'X') ? 'O' : 'X';

  my @open = $grid->open();

  if (scalar(@open) == 9) {
    my @plays = (1,3,5,7,9); # Never play an edge, only the center or a corner

    return $plays[int(rand(4))];
  }

  if (scalar(@open) == 1) {
    return $open[0];     # Single open space. Only possible if AI goes first.
  }

  # Play winning move if only one away.
  if (my $play = $self->need_to_play($grid, $value)) { return $play; }

  # Block opponent if they are one move from winning.
  if (my $play = $self->need_to_play($grid, $next_play)) { return $play; }

  my %scores;
  my $best_block;
  my $best_score;

  for my $block (@open) {
    $grid->set($block, $value);

    my $score = $self->play($grid, $next_play, 0, $best_score);
    if (!$best_block) {
      $best_block = $block;
      $best_score = $score;
    } else {
      if ($score < $best_score) {
        $best_block = $block;
        $best_score = $score;
      }
    }
    $grid->unset($block);
  }
  return $best_block;
}

sub play {
  my ($self, $grid, $value, $score, $best_score) = @_;
  my $player_value = $self->{value};
  my $opponent_value = ($self->{value} eq 'X') ? 'O' : 'X';
  my $next_play = ($value eq 'X') ? 'O' : 'X';

  # Can play with weights here to change style of play
  # This seems to reliably tie some of the smarter human strategies
  if ($grid->is_winner($player_value)) {
    return ($score - 1);
  } elsif ($grid->is_winner($opponent_value)) {
    return ($score + 1);
  } elsif ($grid->is_cats_game) {
    return $score;
  }

  my @open = $grid->open();
  my @results;

  for my $block (@open) {
    if ($best_score && ($best_score < $score)) {  # Pruning
      return $score;
    }

    $grid->set($block, $value);
    $score = $self->play($grid, $next_play, $score, $best_score);
    $grid->unset($block);
  }
  return $score;
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

