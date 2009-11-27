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
from random import randrange

from engine import vforangle, rotate
from physics import Body, Circle, Vec2
from actor import Actor

class Asteroid(Actor):

    # Debug draw colors 
    fill = 255, 0, 0
    outline = 255, 0, 0
    group = 2
    
    ##
    ## INITIALIZATION
    ##

    def __init__(self, melee):
        Actor.__init__(self, melee)
                
        # Randomize velocity
        ub = melee.aabb.upper_bound
        lb = melee.aabb.lower_bound
        x = randrange(lb.x, ub.x)
        y = randrange(lb.y, ub.y)
        av = 0.1
        vx = randrange(-50.0, 50.0)
        vy = randrange(-50.0, 50.0)
        
        # Create body
        bodydef = Body()
        bodydef.ccd = True
        bodydef.position = Vec2(x, y) 
        self.body = melee.world.append_body(bodydef)
        self.body.angular_velocity = av
        self.body.linear_velocity = Vec2(vx, vy)
        
        # Create shape
        self.radius = 1.0
        density = 10.0
        
        c1 = Circle()
        c1.radius = self.radius 
        self.c1_local = -1.0, 1.0
        c1.local_position = Vec2(*self.c1_local)
        c1.density = density
        s1 = self.body.append_shape(c1)
        
        c2 = Circle()
        c2.radius = self.radius 
        self.c2_local = 1.0, 1.0
        c2.local_position = Vec2(*self.c2_local)
        c2.density = density
        s2 = self.body.append_shape(c2)
        
        self.body.set_mass_from_shapes()
        
        # Register shapes for collision callbacks
        melee.contact_register[hash(s1)] = self
        melee.contact_register[hash(s2)] = self
        
    def apply_damage(self, damage):
        """ Asteroids don't take any damage """
        pass
    
    def apply_gravity(self):
        pass