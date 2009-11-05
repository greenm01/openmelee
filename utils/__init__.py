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
import math

# Utility functons. Some of these may eventally be moved

def rotate(v, angle):
    """ Angle is radians """
    cos = math.cos(angle)
    sin = math.sin(angle)
    return (cos * v[0]) - (sin * v[1]), (cos * v[0]) + (sin * v[1])

def clamp(a, low, high):
    return max(low, min(a, high))
    
def cross(v1, v2):
    """The cross product between the vector and other vector
        v1.cross(v2) -> v1.x*v2.y - v2.y*v1.x
    :return: The cross product
    """
    return v1[0]*v2[1] - v1[1]*v2[0]

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
        size = screen.get_size()
        self.sc = size[0]/2.0, size[1]/2.0 # screen center

    def set_view(self, view):
        self.zoom, self.vc = view

    def to_sdl(self, v):
        """Convert point (Vec2) to pygame coordinates"""
        p = (v[0] - self.vc[0]) * self.zoom, (v[1] - self.vc[1]) * self.zoom
        return int(p[0] + self.sc[0]), int(-p[0] + self.sc[0])

    def scale(self, n):
        """Scale physics units to screen coordinates"""
        return int(n * self.zoom)

transform = Transform()
