"""Implementation of the Pig's Dice Game."""

import random

class Player:
    """Player class."""
    score = 0

    def __init__(self, name):
        self.name = name

MAX_SCORE = 100
num_players = int(input('How many players? '))
players = []

for idx in range(num_players):
    name = input('Player {}\'s name: '.format(idx + 1))
    players.append(Player(name))

playing = True
round = 0

while playing:
    # Determine currently active player
    player_idx = round % len(players)
    player = players[player_idx]

    print()
    print('### Player {}\'s turn ###'.format(player_idx + 1))

    # Keep track of the current score
    score = 0

    while True:
        rolled = random.randint(1, 6)
        print('Rolled: {}'.format(rolled))

        # Did player roll a 1?
        if rolled == 1:
            print('You lost it all :-O!')
            score = 0
            break

        score += rolled

        print('On the table: {}'.format(score))

        # Check if player won
        if player.score + score >= MAX_SCORE:
            print('Player {} wins!'.format(player_idx + 1))
            playing = False
            break

        # Does player want to continue?
        keep_playing = input('Keep rolling? [Y/n]: ') or 'y'

        if keep_playing.lower() != 'y':
            break

    player.score += score
    print('Total score: {}'.format(player.score))

    round += 1
