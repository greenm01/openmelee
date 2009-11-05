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
from random import randrange

from engine import vforangle, rotate
from physics import Body, Circle, Vec2
from actor import Actor

class Asteroid(Actor):

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
        self.radius = 0.5
        density = 5.0
        
        c1 = Circle()
        c1.radius = self.radius 
        self.c1_local = -0.5, 0.5
        c1.local_position = Vec2(*self.c1_local)
        c1.density = density
        self.c1 = self.body.append_shape(c1)
        
        c2 = Circle()
        c2.radius = self.radius 
        self.c2_local = 0.5, 0.5
        c2.local_position = Vec2(*self.c2_local)
        c2.density = density
        self.c2 = self.body.append_shape(c2)
        
        self.body.set_mass_from_shapes()

    #def applyGravity(self):
    #    pass
        
    def draw(self):
        from engine import draw_solid_circle
        vec = vforangle(self.body.angle)
        p1 = rotate(vec, self.c1_local)
        p = self.body.position
        c1x = p.x + p1[0]
        c1y = p.y + p1[1]
        p2 = rotate(vec, self.c2_local)
        c2x = p.x + p2[0]
        c2y = p.y + p2[1]
        fill = 255, 0, 0
        draw_solid_circle((c1x, c1y), self.radius, fill, fill) 
        draw_solid_circle((c2x, c2y), self.radius, fill, fill)
