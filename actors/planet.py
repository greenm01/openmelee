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
#
import math

from physics import *

from actor import Actor

class Planet(Actor):

    # Debug draw colors 
    fill = 50, 100, 200
    outline = 255, 0, 0
    group = 1
    
    def __init__(self, melee):
        Actor.__init__(self, melee)
        
        self.damage = 1
        #from utils import squirtle
        file = "data/planet.svg"
        #self.svg = squirtle.SVG(file, anchor_x='center', anchor_y='center')
                
        # Create body
        bodydef = Body()
        bodydef.ccd = True
        bodydef.position = Vec2(0, 0) 
        self.body = melee.world.append_body(bodydef)
        
        # Create shape
        self.radius = 7
        circledef = Circle()
        circledef.radius = self.radius 
        shape = self.body.append_shape(circledef)
        
        # Register shapes for collision callbacks
        melee.contact_register[hash(shape)] = self
    
    def check_death(self):
        pass
        
    def apply_gravity(self):
        pass    

    def apply_damage(self, damage):
        """ Planet doesn't take any damage """
        pass