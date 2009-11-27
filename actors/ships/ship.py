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
from math import pi

from engine import vforangle, rotate
from physics import Vec2, Body, Polygon, BoundPolygon
from actors.actor import Actor
from actors.debris import Debris
from utils import clamp, cross
from utils.geo import calc_center, convex_hull

# Button numbers
THRUST  = 1
LEFT    = 2
RIGHT   = 4
FIRE    = 8
SPECIAL = 16

class Ship(Actor):

    # Button state - 5-bit bitmask, with 1=pressed
    buttons = 0
    # Button state of previous update
    buttons_prev = 0

    pTime = 0.0
    bTime = 0.0
    sTime = 0.0

    ##
    ## INITIALIZATION
    ##

    def __init__(self, melee):
        Actor.__init__(self, melee)
        
        # Set max linear and angular velocity
        self.max_linear_velocity = 50
        self.max_angular_velocity = pi
        
        # Physics (based on SVG shapes)
        self.translate = calc_center(self.lines[self.parts.index(self.center_part)])
        self.svg.init(self.translate, self.scale)
        
        bodydef = Body()
        bodydef.ccd = True
        bodydef.position = self.initial_position
        self.body = melee.world.append_body(bodydef)
        self.body.linear_velocity = self.initial_velocity
        self.body.angular_velocity = self.initial_ang_vel
        
        for p in self.lines:
            polygondef = Polygon()
            polygondef.density = self.density
            # Ensure points are oriented ccw
            ccw = convex_hull(p)
            # Translate and scale points
            verts = []
            for v in ccw:
                x = (v[0] - self.translate[0]) * self.scale
                y = (v[1] - self.translate[1]) * self.scale
                verts.append(Vec2(x, y))   
            polygondef.vertices = verts
            polygondef.collision_group = self.group
            shape = self.body.append_shape(polygondef)
            # Register shapes for collision callbacks
            melee.contact_register[hash(shape)] = self
            
        self.body.set_mass_from_shapes()

    ##
    ## CONTROLLER INTERFACE
    ##

    def thrust(self):
        f = self.forward()
        self.body.apply_impulse(Vec2(f[0], f[1]), self.body.world_center)

    def turn_straight(self):
        self.body.angular_velocity = 0

    def turn_left(self):
        self.body.angular_velocity = 0
        t = cross(self.left_turn_point, self.turn_force)
        self.body.apply_torque(t)

    def turn_right(self):
        self.body.angular_velocity = 0
        t = cross(self.right_turn_point, self.turn_force)
        self.body.apply_torque(t)

    def fire(self):
        pass

    def special(self):
        pass
        
    def forward(self):
        a = vforangle(self.body.angle)
        return rotate(self.engine_force, a)

    ##
    ## MAINLOOP INTERFACE
    ##

    def update_ai(self):
        if self.ai:
            self.ai.update()
            
    def update_state(self):
        buttons = self.buttons
        buttons_delta = self.buttons_prev ^ buttons

        self.time = self.melee.time   
        self.recharge_battery()

        if not self.buttons & SPECIAL:
            # Steering -- yep, it's this complicated.
            # When you press left or right, start turning that direction.
            # When you release left AND right, stop turning.
            rudder_delta = buttons_delta & (LEFT | RIGHT)
            if rudder_delta:
                rudder = buttons & (LEFT | RIGHT)
                if rudder:
                    if rudder & rudder_delta & LEFT:
                        print "LEFT"
                        self.turn_left()
                    elif rudder & rudder_delta & RIGHT:
                        print "RIGHT"
                        self.turn_right()
                else:
                    print "STRAIGHT"
                    self.turn_straight()

        if buttons & FIRE:
            self.fire()
          
        if (buttons & THRUST):
            self.thrust()

        self.update_special()

        self.buttons_prev = buttons

    ##
    ## HELPERS ?
    ##

    def battery_cost(self, cost):
		b = self.battery - cost
		self.battery = int(clamp(b, 0, self.battery_capacity))
    
    def primary_time(self):
		dt = self.time - self.pTime
		if dt >= self.pDelay:
			self.pTime = self.time
			return True
		return False
    
    def recharge_battery(self): 
		dt = self.time - self.bTime
		if dt >= self.bDelay and self.battery < self.battery_capacity:
			self.bTime = self.time
			self.battery += 1

    def on_destroy(self):
        # Create explosion
        for s in self.body.shapes:
            bodydef = Body()
            bodydef.ccd = True
            debris = self.melee.world.append_body(bodydef)
            debris.linear_velocity = Vec2(randrange(-100.0, 100.0), 
                                        randrange(-100.0, 100.0))
            junk = Debris(self.melee, debris)
            if isinstance(s, BoundPolygon):
                # Polygon
                debris.position = self.body.position + s.centroid
                polydef = Polygon()
                polydef.density = 10
                polydef.vertices = s.vertices
                shape = debris.append_shape(polydef)
                # Register shapes for collision callbacks
                self.melee.contact_register[hash(shape)] = junk
            else:
                # Circle
                debris.position = self.body.position + s.local_position
                circdef = Circle()
                circdef.density = 10
                circle.radis = s.radius
                shape = debris.append_shape(circdef)
                self.melee.contact_register[hash(shape)] = junk
                
            debris.set_mass_from_shapes()