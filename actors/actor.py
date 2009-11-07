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
import sys
import time

from engine import calc_planet_gravity, vforangle, rotate
from engine import draw_solid_circle, draw_solid_polygon, draw_circle
from physics import Vec2, BoundPolygon, BoundCircle
from utils.geo import calc_center

class Actor:

    def __init__(self, melee):
        self.melee = melee
        
        # TODO 'permanent' objects should not have a lifetime... only bullets etc.
        try:
            self.lifetime = sys.float_info.max
        except AttributeError:
            self.lifetime = 1e308

        self.damage = 5
        self.dead = False

        melee.actors.append(self)
        self.birthday = time.time()

        # Load SVG file
        if hasattr(self, 'parts') and hasattr(self, 'name'):
            from utils import squirtle
            file = "data/ships/%s.svg" % self.name
            self.svg = squirtle.SVG(file, anchor_x='center', anchor_y='center')
            self.lines = list(self.svg.shapes[part] for part in self.parts)
            
    def draw(self):
        pass
    
    def debug_draw(self):
        pos = self.body.position
        angle = vforangle(self.body.angle)
        for s in self.body.shapes:
            verts = []
            if isinstance(s, BoundPolygon):
                # Draw polygon
                for v in s.vertices:
                    p = rotate(angle, (v.x, v.y))
                    px = pos.x + p[0]
                    py = pos.y + p[1]
                    verts.append((px, py))
                draw_solid_polygon(verts, self.fill, self.outline)
            else:
                # Draw circle
                v = s.local_position
                p = rotate(angle, (v.x, v.y))
                c1x = pos.x + p[0]
                c1y = pos.y + p[1]
                draw_solid_circle((c1x, c1y), s.radius, self.fill, self.outline) 
        
        # Draw center of mass
        #red = 255, 0, 0
        #draw_circle((pos.x, pos.y), 0.5, red) 
            
    def check_death(self):
        age = time.time() - self.birthday
        if age >= self.lifetime or self.dead:
            self.kill()
            return True
        return False

    # Apply planet gravity
    def apply_gravity(self):
        p = self.body.position
        fx, fy = calc_planet_gravity(p.x, p.y)
        self.body.apply_force(Vec2(fx, fy), self.body.world_center)
    
    def apply_damage(self, damage):
        self.health -= damage
        if self.health <= 0:
            print "I'm dead!"
            self.dead = True
    
    def update_state(self):
		#state.pos.set(rBody.x, rBody.y)
		#state.linVel = rBody.v
        pass
 
    def kill(self):
        self.destroy()
        self.melee.actors.remove(self)
        self.melee.world.remove_body(self.body)

    def destroy(self):
        pass