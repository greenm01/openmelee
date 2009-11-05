# Copyright 2009 Mason Green & Tom Novelli
#
# This file is part of OpenMelee.
#
# OpenMelee is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMelee is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>.

import config

class KeyboardPlayer: pass

keymap = {}  # key : (player, button#)
def compute_keymap():
    for player, keyset in enumerate(config.KEYS):
        for button, key in enumerate(keyset):
            keymap[key] = player, button
            
compute_keymap()
for k in keymap:
    print k
    
def process_events(game):
    "Called once per game loop to process I/O events"
    for e in pygame.event.get():
        if e.type == pygame.QUIT:
            return True
        elif e.type == pygame.KEYDOWN:
            if e.key == pygame.K_ESCAPE:
                return True
            # XXX TEST ROLLBACK
            if e.key == pygame.K_BACKSPACE:
                game.history.rollback()
                return
            update_ship(game, e.key, 1)
        elif e.type == pygame.KEYUP:
            update_ship(game, e.key, 0)


def update_ship(game, key, press):
    "Given a key event, look up the player/ship and update its button bitmask."
    # Lookup key
    try:
        player, button = keymap[key]
    except KeyError:
        # Key is not mapped to anything
        return
    
    # Abort if player is not keyboard-controlled
    if not isinstance(game.players[player], KeyboardPlayer):
        print "Player %d is not keyboard controlled." % player
        return

    # Update Ship.buttons bitmask
    bit = 1 << button
    if press:
        game.actors[player].buttons |= bit
        #game.players[player].on_key_press(n)
    else:
        game.actors[player].buttons &= (0x1f ^ bit)
        #game.players[player].on_key_release(n)

    game.button_change = True
