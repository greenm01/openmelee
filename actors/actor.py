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
import sys
import time

from physics import Vec2
from utils.geo import calc_center

class Actor(object):
    is_actor = True

    def __init__(self, melee):
        self.melee = melee

        # Default values
        self.group = 0
        
        # TODO 'permanent' objects should not have a lifetime... only bullets etc.
        try:
            self.lifetime = sys.float_info.max
        except AttributeError:
            self.lifetime = 1e308

        self.damage = 5
        self.healthCapacity = sys.maxint
        self.health = sys.maxint
        self.dead = False

        if self.is_actor:
            melee.actors.append(self)
            self.birthday = time.time()

        # Load SVG file
        if hasattr(self, 'parts') and hasattr(self, 'name'):
            if self.melee.backend == 'gl':
                from utils import squirtle
            elif self.melee.backend == 'sdl':
                from utils import squirtle_noGL as squirtle

            file = "data/ships/%s.svg" % self.name
            self.svg = squirtle.SVG(file, anchor_x='center', anchor_y='center')
            self.lines = list(self.svg.shapes[part] for part in self.parts)

            if self.melee.backend == 'sdl':
                # Load/generate image
                # TODO generate from SVG during build script - use 'rsvg'
                import pygame
                file = "data/ships/%s.png" % self.name
                try:
                    self.image = pygame.image.load(file)
                except:
                    print "Failed to load bitmap file '%s' - using SVG instead" % file
                    self.image = self.rasterize_svg()


    def draw(self, surface, view):
    
        zoom, vc = view

        x = self.body.position.x
        y = self.body.position.y
        a = (self.body.angle * 57.3) + 180.0    # convert to degrees

        if self.melee.backend == 'gl':
            self.svg.draw(x, y, angle = a)
            self.debugDraw()

        elif self.melee.backend == 'sdl':
            import pygame
            from utils import transform
            """
            img = pygame.transform.rotozoom(self.image, a, zoom)
            p = self.body.position
            x1,y1 = transform.to_sdl((p.x, p.y))
            w,h = img.get_size()
            cx,cy = w/2, h/2
            surface.blit(img, (x1-cx, y1-cy))
            """
            
            # Vector drawing (probably too slow)
            W,H = surface.get_size()
            cx = x * zoom + W/2
            cy = y * zoom + H/2
            #print cx,cy
            for shape in self.lines:
                pointlist = [(int(p[0]*zoom)+cx, int(p[1]*zoom)+cy) for p in shape]
                pygame.draw.lines(surface, (0,255,0), False, pointlist)

            # Center crosshair
            pygame.draw.line(surface, (0,0,255), (cx-10,cy), (cx+10,cy))
            pygame.draw.line(surface, (0,0,255), (cx,cy-10), (cx,cy+10))
            

    def rasterize_svg(self):

        # 1. Compute bounding box & size
        from itertools import chain
        from utils import bounding_box
        x1,y1,x2,y2 = bounding_box(list(chain(*self.lines)))
        w,h = x2-x1, y2-y1
        #print "Bounds: ", x1,y2,x2,y2
        #print "Size: ", w,h

        # 2. Render to bitmap image (XXX it's way bigger than necessary)
        import pygame
        image = pygame.Surface((w,h))
        for shape in self.lines:
            pointlist = [(int(p.x)-x1, int(p.y)-y1) for p in shape]
            pygame.draw.lines(image, (0,255,0), False, pointlist, max(1,w/15))

        return image
        
    def check_death(self):
        age = time.time() - self.birthday
        if age >= self.lifetime:
            self.destroy()
            self.dead = True
            self.melee.actors.remove(self)
            self.melee.world.remove(self.body)
            return True
        return False

    # Apply planet gravity
    def apply_gravity(self):
        minRadius = 1
        maxRadius = 30
        strength = 400
     
        center = Vec2(0, 0)
        rx = center.x - self.body.position.x
        ry = center.y - self.body.position.y
        d = math.sqrt(rx * rx + ry * ry)
        rx /= d
        ry /= d
        ratio = (d - minRadius) / (maxRadius - minRadius)
        
        if ratio < 0.0:
            ratio = 0.0
        elif ratio > 1.0:
            ratio = 1.0
        
        force = Vec2(rx * ratio * strength, ry * ratio * strength)
        center = self.body.local_center
        self.body.apply_force(force, center)
    
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
        
    def destroy(self):
        pass
