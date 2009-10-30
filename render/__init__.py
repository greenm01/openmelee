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
from math import pi, sin, cos

from pyglet.gl import *

from pymunk import Vec2d

# Color for drawing. Each value has the range [0,1].
class Color():
    # Red, green, blue
    def __init__(self, r, g, b):
       self.r = r
       self.g = g
       self.b = b 

SEGMENTS = 25
INCREMENT = 2.0 * pi / SEGMENTS
    
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

