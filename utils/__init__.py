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
import math
from pymunk import Vec2d

# Utility functons. Some of these may eventally be moved

def rotate(v, angle):
    cos = math.cos(angle)
    sin = math.sin(angle)
    return Vec2d((cos * v.x) - (sin * v.y), (cos * v.y) + (sin * v.x))
    
def clamp(a, low, high):
    return max(low, min(a, high))
    
# Color for drawing. Each value has the range [0,1].
class Color():
    # Red, green, blue
    def __init__(self, r, g, b):
       self.r = r
       self.g = g
       self.b = b 

def bounding_box(pointlist): 	
    from math import floor, ceil
    xs = [p.x for p in pointlist]
    ys = [p.y for p in pointlist]
    x1 = int(floor(min(xs)))
    y1 = int(floor(min(ys)))
    x2 = int(ceil(max(xs)))
    y2 = int(ceil(max(ys)))
    return x1,y1,x2,y2


class Transform:
    def set_screen(self, screen):
        """screen: pygame.Surface instance"""
        size = Vec2d(screen.get_size())
        self.sc = size / 2.0   # screen center

    def set_view(self, view):
        self.zoom, self.vc = view

    def to_sdl(self, p):
        """Convert pymunk point (Vec2d) to pygame coordinates"""
        p = (p - self.vc) * self.zoom
        return int(p.x + self.sc.x), int(-p.y + self.sc.x)

    def scale(self, n):
        """Scale pymunk units to screen coordinates"""
        return int(n * self.zoom)

transform = Transform()
