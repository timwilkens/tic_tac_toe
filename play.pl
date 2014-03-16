#!/usr/bin/perl

use strict;
use warnings;
use Grid;
use AI;

my $board = Grid->new();
my $player = AI->new();
my $value = 'X'; # X goes first

while (1) {

  $board->show();
  print "Player $value: ";
  my $block;

  if ($value eq ('X')) {
    $block = <STDIN>;
    chomp($block);
  } else {
    $block = $player->choose_play($board, 'O');
    print "$block\n";
  }

  $board->set($block, $value);

  if ($board->is_winner($value)) {
    $board->show();
    print "Player $value wins!\n";
    exit;
  }

  if ($board->is_cats_game) {
    $board->show();
    print "It's a tie!\n";
    exit;
  }
  $value = ($value eq 'X') ? 'O' : 'X';
}
