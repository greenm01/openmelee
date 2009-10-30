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

