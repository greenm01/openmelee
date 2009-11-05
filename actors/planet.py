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

from physics import *

from actor import Actor

class Planet(Actor):
    is_actor = False

    def __init__(self, melee):
        Actor.__init__(self, melee)
        
        #from utils import squirtle
        file = "data/planet.svg"
        #self.svg = squirtle.SVG(file, anchor_x='center', anchor_y='center')
                
        # Create body
        bodydef = Body()
        bodydef.position = Vec2(0, 0) 
        self.body = melee.world.append_body(bodydef)
        
        # Create shape
        self.radius = 7
        circledef = Circle()
        circledef.radius = self.radius 
        self.body.append_shape(circledef)
    
    def check_death(self):
        pass
        
    def apply_gravity(self):
        pass
        
    def draw(self):
        from engine import draw_solid_circle
        
        x = self.body.position.x
        y = self.body.position.y
        #a = self.body.angle * 57.2957795     # convert to degrees

        #self.svg.draw(x, y, angle=a)

        center = x, y
        fill = 50, 100, 200
        outline = 255, 0, 0
        draw_solid_circle(center, self.radius, fill, outline)
       