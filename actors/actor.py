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
import time
import sys

from pyglet.gl import *
from pymunk import Vec2d

class Actor():

    def __init__(self, melee):
        self.melee = melee
        # Default values
        self.group = 0
        self.lifetime = sys.float_info.max
        self.damage = 5
        self.healthCapacity = sys.maxint
        self.health = sys.maxint
        self.dead = False
        melee.actors.append(self)
        self.birthday = time.time()
        
    def check_death(self):
        age = time.time() - self.birthday
        if age >= self.lifetime:
            self.destroy()
            self.dead = True
            self.melee.actors.remove(self)
            self.melee.space.remove(self.body)
            return True
        return False

    # Apply planet gravity
    def apply_gravity(self):
        minRadius = 1
        maxRadius = 3000
        strength = 4000
     
        center = Vec2d(0, 0)
        r = center - self.body.position
        d = math.sqrt(r.x * r.x + r.y * r.y)
        r /= d
        ratio = (d - minRadius) / (maxRadius - minRadius)
        
        if ratio < 0.0:
            ratio = 0.0
        elif ratio > 1.0:
            ratio = 1.0
        
        self.body.apply_force(r * ratio * strength)
    
    def apply_damage(self, damage):
		self.health -= damage
		if self.health <= 0:
			self.destroy()
			self.dead = True
			#melee.destroyList.set(rBody);
        
    def debug_draw(self):
        for s in self.shapes:
            self.drawPolyShape(s)
    
    def update_state(self):
		#state.pos.set(rBody.x, rBody.y)
		#state.linVel = rBody.v
        pass

    '''
    def calcRadius(self):
		for s in self.body.shapes:
			if s.type == phx.Shape.CIRCLE:
				if s.r > self.radius: self.radius = s.r
			else:
				// Polygon
				var poly : phx.Polygon = cast(s);
				var v = poly.verts;
				while (v != null) {
					var l = v.length();
					if (l > radius) radius = l;
					v = v.next;
				}
			}
		}
		
        #state.radius = radius;
	'''
        
    def draw(self):
        pass
        
    def destroy(self):
        pass
