'''
Copyright 2009 Mason Green & Tom Novelli

This file is part of OpenMelee.

OpenMelee is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

OpenMelee is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>.
'''
from config import MAX_LAG
from collections import deque
import pygame

class History:
    def __init__(self, game):
        self.game = game
        self.state = self.game.serialize()
        self.time = pygame.time.get_ticks()

        # Event Queue = {time : [event, ...], ...}
        self.eq = {}

        # State Queue/history = [(time, state), ...]
        maxlen = MAX_LAG / game.ts_ms * 2
        try:
            self.sq = deque(maxlen=maxlen)
        except TypeError:
            self.sq = deque()  # Python < 2.6

    def update(self, t):
        # Save current state to history
        self.sq.append((t, self.game.serialize()))

        # Purge old history
        oldest = t - MAX_LAG
        while self.sq[0][0] < oldest:
            self.sq.popleft()

        # Purge old events
        for etime in self.eq.iterkeys():
            if etime < self.time:
                del self.eq[etime]

    def rollback(self):
        "Rollback to oldest saved state and replay events."
        dt = self.game.ts_ms

        t, state = self.sq[0]
        self.game.deserialize(state)
        self.sq.clear()

        t1 = pygame.time.get_ticks()

        for etime, e in sorted(self.eq.iteritems()):
            while t < etime:
                self.game.update()
                self.update(t)
                t += dt
                print 'e',

            # TODO apply event

        while t < self.game.time:
            self.game.update()
            self.update(t)
            t += dt
            #print '.',

        self.time = t

        t2 = pygame.time.get_ticks()
        print
        print "Replayed to t=%d (took %dms)" % (t, t2-t1)
