#
# Copyright (c) 2009 Mason Green & Tom Novelli
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
#'
import pyglet
from pyglet.window import Window as GLWindow
from pyglet import clock
from pyglet.gl import *
from utils import squirtle

import players.kbd_gl as kbd

class Window(GLWindow):
    "Pyglet interface"
    backend = 'sdl'

    counter = 0

    def __init__(self):
        vs = True  # limit FPS or something

        try:
            # Try and create a window with multisampling (antialiasing)
            config = Config(sample_buffers=1, samples=4, 
                          depth_size=16, double_buffer=True,)
            GLWindow.__init__(self, self.sizeX, self.sizeY, vsync=vs, 
                              resizable=False, config=config)
        except pyglet.window.NoSuchConfigException:
            # Fall back to no multisampling for old hardware
            super(Melee, self).__init__(self.sizeX, self.sizeY, vsync=vs, 
                                        resizable=False)
        
        # Initialize OpenGL
        squirtle.setup_gl()

    def get_time_ms(self):
        from time import time
        return int(time() * 1000.0)

    def on_draw(self):
        #TODO Cull objects outside zoom window
        self.counter += 1
        if self.counter == 60:
            self.counter = 0
            self.set_caption("OpenMelee Demo, FPS = " + str(int(clock.get_fps())))

        view = self.calcView()
        zoom, viewCenter = view

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

        # Common to SDL and GL renderers:
        self.planet.draw(self.screen, view)

        for s in self.actors:
            if s:
                s.draw(self.screen, view)

        # Draw world bounding box
        c = 0.3, 0.9, 0.9
        ub = self.upperBound
        lb = self.lowerBound 
        verts = [Vec2d(lb.x, ub.y), Vec2d(lb.x, lb.y), 
                 Vec2d(ub.x, lb.y), Vec2d(ub.x, ub.y)]
        glColor3f(*c)
        glBegin(GL_LINE_LOOP)
        for v in verts:
            glVertex2f(v.x, v.y)
        glEnd()

    def on_key_press(self, symbol, modifiers):
        kbd.update_ship(self, symbol, 1)

    def on_key_release(self, symbol, modifiers):
        kbd.update_ship(self, symbol, 0)

    def on_mouse_press(self, x, y, button, modifiers):
        print 'Mouse button pressed in game'

    def mainloop(self):
        pyglet.clock.schedule(self.update)
        #pyglet.vsync = 0
        pyglet.app.run()


from math import pi, sin, cos

SEGMENTS = 25
INCREMENT = 2.0 * pi / SEGMENTS
    
# Color for drawing. Each value has the range [0,1].
class Color():
    # Red, green, blue
    def __init__(self, r, g, b):
       self.r = r
       self.g = g
       self.b = b 

def draw_solid_circle(center, radius, fill, outline):
    global k_segments, theta

    cx = center.x
    cy = center.y

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(0.5 * fill.r, 0.5 * fill.g, 0.5 * fill.b, 0.5)

    c = cos(INCREMENT)
    s = sin(INCREMENT)

    points = []
    x = radius
    y = 0

    for i in range(SEGMENTS ):
        points.append([x + cx, y + cy])
        t = x
        x = c * x - s * y
        y = s * t + c * y
        
    glBegin(GL_TRIANGLE_FAN)
    for p in points:
        glVertex2f(p[0], p[1])
    glEnd()
    glDisable(GL_BLEND)

    glColor3f(outline.r, outline.g, outline.b)
    glBegin(GL_LINE_LOOP)
    for p in points:
        glVertex2f(p[0], p[1])
    glEnd()
    
def draw_circle(self, center, radius):
    theta = 0.0
    glColor3f(1, 0, 0)
    glBegin(GL_LINE_LOOP)
    for i in range(SEGMENTS ):
        v = center + Vec2d(cos(theta), sin(theta)) * radius
        glVertex2f(v.x, v.y)
        theta += INCREMENT
    glEnd()
    
def draw_polygon(poly, color):
    body = poly.body
    glColor3f(color.r, color.g, color.b)
    glBegin(GL_LINE_LOOP)
    for vert in poly.verts:
        v = body.position + vert.cpvrotate(body.rotation_vector)
        glVertex2f(v.x, v.y)
    glEnd()

