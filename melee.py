#!/usr/bin/env python2.6
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
from actors.asteroid import Asteroid
from actors.planet import Planet
from history import History
from players.net import NetConn, NetPlayer
from pymunk import Vec2d

#from render.gl import Window
from render.sdl import Window

import config
import os
import pymunk
import struct
import sys

NUM_ASTEROIDS = 7

class Melee(Window):
    WINDOW_POSITION = "800,0"

    frameRate = 30
    timeStep = 1.0 / frameRate
    ts_ms = timeStep * 1000.0

    sizeX = 800
    sizeY = 600

    button_change = False   # Buttons pressed/released _locally_ since update?

    # Space upper and lower bounds
    upperBound = Vec2d(20000.0, 20000.0)
    lowerBound = Vec2d(-20000.0, -20000.0)

    vs = True

    ##
    ## INITIALIZATION
    ##

    def __init__(self): 
        Window.__init__(self)

        self.set_caption("OpenMelee Demo")
        
        # Init network
        if REMOTE:
            self.net = NetConn(LOCAL, REMOTE, self)

            if LOCAL[1] == 8888:
                self.local_player, self.remote_player = 0,1
            else:
                self.local_player, self.remote_player = 1,0

            config.PLAYERS[self.remote_player] = NetPlayer
        else:
            self.net = None
      
        # Initialize Chipmunk physics engine
        pymunk.init_pymunk()
        self.space = pymunk.Space()
        
        # Create players/controllers
        self.players = list(cls() for cls in config.PLAYERS)

        # Create game objects (they add themselves to self.actors if necessary)
        self.actors = []

        for i in 0,1:
            ship = config.SHIP_CHOICES[i]
            #player = self.players[i]
            config.SHIP_CLASSES[ship](self)  # , player ?

        self.planet = Planet(self)
  
        for i in range(NUM_ASTEROIDS):
            Asteroid(self)
        
        # Save state for rollback
        self.time = self.get_time_ms()
        self.history = History(self)

        # Network handshake  # TODO move to NetConn and randomize master/slave
        if self.net:
            if self.local_player == 0:
                # Master
                self.net.handshake()
            else:
                # Slave
                state = self.net.wait_handshake()
                if state:
                    self.deserialize(state)
                else:
                    print "Network handshake failed or timed out"
                    return

        self.mainloop()

    ##
    ## NETWORK
    ##
        
    def serialize(self):  # TODO move to NetConn
        lst = []
        for ship in self.actors:
            s = ship.body
            lst += (list(s.position)
                   +list(s.velocity)
                   +[s.angle, s.angular_velocity]
                   )
        n = len(self.actors)
        return struct.pack("!B %df" % (n*6), n, *lst)

    def deserialize(self, state):
        nlen = 1  # Encoded length of 'n'
        n, = struct.unpack("!B", state[:nlen])
        if (len(state) - nlen) != (struct.calcsize("!6f") * n):
            print "deserialize(): PACKET SIZE MISMATCH -- PACKET DROPPED"
            return
        lst = struct.unpack("!%df" % (n*6), state[nlen:])
        for i,ship in enumerate(self.actors):
            s = ship.body
            p = lst[i*6 : (i+1)*6]
            s.position = Vec2d(p[0], p[1])
            s.velocity = Vec2d(p[2], p[3])
            s.angle = p[4]
            s.angular_velocity = p[5]

    ##
    ## EVENTS
    ##

    def update(self):
        # TODO handle frame skips... repeat until self.time < pygame time ?

        # Update states
        for a in self.actors:
            if a.check_death(): continue
            a.update_state()
            a.apply_gravity()
        
        # Update game mechanics
        self.space.step(self.timeStep)
        
        # End of frame maintenance 
        for a in self.actors:
            a.body.reset_forces()
            if not self.inBounds(a.body):
                self.boundaryViolated(a.body)

        self.time += self.ts_ms
        self.history.update(self.time)
        
    ##
    ## PRIVATE HELPER METHODS
    ##

    def calcView(self):
        from utils import clamp, bounding_box

        # Zoom in on the ships (and planet?)
        objects = self.actors[:2] #+ [self.planet]
        points = [o.body.position for o in objects]

        r = self.planet.radius
        x1,y1,x2,y2 = bounding_box(points)
        point1 = Vec2d(x1,y1) - r
        point2 = Vec2d(x2,y2) + r
            
        range = point1 - point2
        #zoom = clamp(1000.0/range.length, 0.05, 0.3)
        zoom = min(1000.0/range.length, 0.3)    # no maximum zoom-out!
        viewCenter = point1 - (range * 0.5)

        zoom *= 0.4   # XXX fudge factor... zoom calcs aren't quite right for SDL

        return zoom, viewCenter
 	
    def inBounds(self, body):
        ub = self.upperBound
        lb = self.lowerBound
        
        if body.position.x > ub.x or body.position.x < lb.x:
            return False
        if body.position.y > ub.y or body.position.y < lb.y:
            return False
        return True
        
    def boundaryViolated(self, body):
        ub = self.upperBound
        lb = self.lowerBound
        
        if body.position.x > ub.x:
            x = lb.x + 5
            body.position = Vec2d(x, body.position.y)
        elif body.position.x < lb.x:
            x = ub.x - 5
            body.position = Vec2d(x, body.position.y)
        elif body.position.y > ub.y:
            y = lb.y + 5
            body.position = Vec2d(body.position.x, y)
        elif body.position.y < lb.y:
            y = ub.y - 5
            body.position = Vec2d(body.position.x, y)
                    

if __name__ == '__main__':
    '''
    Usage: melee.py [[remote-address]:port] [local-port] [position]
    '''
    REMOTE = None
    LOCAL  = ('', 8888)
    if len(sys.argv) > 1:
        a = sys.argv[1].split(':')
        REMOTE = (a[0], int(a[1]))
    if len(sys.argv) > 2:
        LOCAL = ('', int(sys.argv[2]))
    if len(sys.argv) > 3:
        Melee.WINDOW_POSITION = sys.argv[3]

    window = Melee()

