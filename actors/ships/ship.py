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
import time

from engine import vforangle, rotate
from physics import *
from actors.actor import Actor
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

    def __init__(self, melee, group):
        Actor.__init__(self, melee)
               
        # Physics (based on SVG shapes)
        translate = calc_center(self.lines[self.parts.index(self.center_part)])
                
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
                x = (v[0] - translate[0]) * self.scale
                y = (v[1] - translate[1]) * self.scale
                verts.append(Vec2(x, y))   
            polygondef.vertices = verts
            polygondef.collision_group = group
            shape = self.body.append_shape(polygondef)
            # Register shapes for collision callbacks
            melee.contact_register[hash(shape)] = self
            
        self.body.set_mass_from_shapes()

    ##
    ## CONTROLLER INTERFACE
    ##

    def thrust(self):
        a = vforangle(self.body.angle)
        f = rotate(self.engineForce, a)
        self.body.apply_impulse(Vec2(f[0], f[1]), self.body.world_center)

    def turn_left(self):
        t = cross(self.leftTurnPoint, self.turnForce)
        self.body.apply_torque(t)

    def turn_right(self):
        t = cross(self.rightTurnPoint, self.turnForce)
        self.body.apply_torque(t)

    def fire(self):
        pass

    def special(self):
        pass

    ##
    ## MAINLOOP INTERFACE
    ##

    def update_state(self):
    
        buttons_changed = self.buttons_prev ^ self.buttons

        self.time = self.melee.time   
        self.recharge_battery()

        if buttons_changed & LEFT and (not self.buttons & SPECIAL):
            if self.buttons & LEFT:
                self.turn_left()
            else:
                self.body.angular_velocity = 0

        if buttons_changed & RIGHT and (not self.buttons & SPECIAL):
            if self.buttons & RIGHT:
                self.turn_right()
            else:
                self.body.angular_velocity = 0

        if (self.buttons & FIRE) and (not self.buttons & SPECIAL):
            self.fire()
          
        self.update_special()

        if (self.buttons & THRUST):
            self.thrust()

        self.buttons_prev = self.buttons

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
