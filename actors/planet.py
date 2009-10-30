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

import pymunk as pm
from pymunk import Vec2d

from actor import Actor
from utils import squirtle
from render import Color, draw_solid_circle

class Planet(Actor):

    def __init__(self, space):
        
        file = "data/planet.svg"
        self.svg = squirtle.SVG(file, anchor_x='center', anchor_y='center')
        
        mass = pm.inf
        inertia = pm.inf
        center = Vec2d(0,0)
        self.body = pm.Body(mass, inertia)  
        self.body.position = center
        self.radius = 1000
        shape = pm.Circle(self.body, self.radius, center)  
        space.add_static(shape)
        
    def draw(self):
        
        x = self.body.position.x
        y = self.body.position.y
        # convert to degrees
        a = self.body.angle * 57.2957795
        
        #self.svg.draw(x, y, angle=a)
        
        center = self.body.position
        fill = Color(0.5, 0.8, 0.5)
        outline = Color(1, 0, 0)
        
        draw_solid_circle(center, self.radius, fill, outline)
        
    
