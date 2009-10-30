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
from math import pi, sin, cos, floor
import time 

import pyglet
from pyglet.window import Window, key
from pyglet import clock
from pyglet.gl import *

import pymunk as pm
from pymunk import Vec2d

from utils import squirtle
from actors.ships.kzerZa import KzerZa
from actors.ships.nemesis import Nemesis
from actors.planet import Planet
from actors.asteroid import Asteroid
from players import Human
from utils import clamp
from render import Color

class Melee(Window):
    
    def __init__(self): 
        
        NUM_ASTEROIDS = 7
        
        # Vertical retrace synchronisation
        # Set to false to limit FPS
        vs = True
        
        #clock.set_fps_limit(90)
        self.timeStep = 1.0/60.0
        
        self.sizeX = 800
        self.sizeY = 600

        # Space upper and lower bounds
        self.upperBound = Vec2d(30000.0, 30000.0)
        self.lowerBound = Vec2d(-30000.0, -30000.0)
        
        try:
            # Try and create a window with multisampling (antialiasing)
            config = Config(sample_buffers=1, samples=4, 
                          depth_size=16, double_buffer=True,)
            super(Melee, self).__init__(self.sizeX, self.sizeY, vsync=vs, 
                                        resizable=False, config=config)
        except pyglet.window.NoSuchConfigException:
            # Fall back to no multisampling for old hardware
            super(Melee, self).__init__(self.sizeX, self.sizeY, vsync=vs, 
                                        resizable=False)
        
        # Initialize OpenGL
        squirtle.setup_gl()
      
        #Initialize chipmunk
        pm.init_pymunk()
        self.space = pm.Space()
        
        # Game ship list
        self.actors = []
        # Create ships
        kzerZa = KzerZa(self)
        nemesis = Nemesis(self)
        
        # Create asteroids
        for i in range(NUM_ASTEROIDS):
            asteroid = Asteroid(self)
        
        # Add ship to human player
        self.human = Human(kzerZa)
        # Create the planet
        self.planet = Planet(self.space)
        self.enemy = False
    
    def update(self, dt):
        
        global iters
        
        # Update states
        for actor in self.actors:
            if actor.check_death(): continue
            actor.update_state()
            actor.apply_gravity()
        
        # Update game mechanics
        self.space.step(self.timeStep)
            
        # End of frame maintenance 
        for actor in self.actors:
            # Reset forces
            actor.body.reset_forces()
            # Check and correct for out of bounds 
            if not self.inBounds(actor.body):
                self.boundaryViolated(actor.body)
    
    # TODO: Refactor this into a specalzed rendering class
    def on_draw(self):
        
        #TODO Cull objects outside zoom window
        self.set_caption("OpenMelee Demo, FPS = " + str(int(clock.get_fps())))
        
        zoom, viewCenter = self.calcView()
        
        glLoadIdentity()
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        
        left = -self.sizeX / zoom
        right = self.sizeX / zoom
        bottom = -self.sizeY / zoom
        top = self.sizeY / zoom
      
        gluOrtho2D(left, right, bottom, top)
        glTranslatef(-viewCenter.x, -viewCenter.y, 0)
        glMatrixMode(GL_MODELVIEW)
        glDisable(GL_DEPTH_TEST)
        glLoadIdentity()
        glClear(GL_COLOR_BUFFER_BIT)
        
        for actor in self.actors:
            actor.draw()
            
        self.planet.draw()
        
        ub = self.upperBound
        lb = self.lowerBound 

        verts = [Vec2d(lb.x, ub.y), Vec2d(lb.x, lb.y), 
                 Vec2d(ub.x, lb.y), Vec2d(ub.x, ub.y)]
                 
        # Draw world bounding box
        c = Color(0.3, 0.9, 0.9)
        glColor3f(c.r, c.g, c.b)
        glBegin(GL_LINE_LOOP)
        for v in verts:
            glVertex2f(v.x, v.y)
        glEnd()
        
    def calcView(self):
        
        ship1 = self.actors[0]
        ship2 = self.actors[1] if self.actors[1] else self.planet
            
        point1 = ship1.body.position
        point2 = ship2.body.position
        range = point1 - point2
        zoom = clamp(1000.0/range.length, 0.025, 0.3)
        viewCenter = point1 - (range * 0.5)
        return (zoom, viewCenter)
 	
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
                    
    def on_mouse_press(self, x, y, button, modifiers):
        print 'Mouse button pressed in game'
    
    def on_key_press(self, symbol, modifiers):
        self.human.onKeyDown(symbol)
        
    def on_key_release(self, symbol, modifiers):
        self.human.onKeyUp(symbol)

                            	
if __name__ == '__main__':
  window = Melee()
  pyglet.clock.schedule(window.update)
  #pyglet.vsync = 0
  pyglet.app.run()
