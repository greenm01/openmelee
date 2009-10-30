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
import time

from actors.actor import Actor
from utils import *

class Ship(Actor):
    
    def __init__(self, melee):
        Actor.__init__(self, melee)
        
        # Key states
        self.engines = False
        self.turnR = False
        self.turnL = False
        self.primary = False
        self.special = False
        
        self.pTime = 0.0
        self.bTime = 0.0
        self.sTime = 0.0
    
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
	    
    def thrust(self):
        force = rotate(self.engineForce, self.body.angle)
        self.body.apply_force(force)
    
    def turn_left(self):
        self.body.torque += self.leftTurnPoint.cross(self.turnForce)
 
    def turn_right(self):
        self.body.torque += self.rightTurnPoint.cross(self.turnForce)
    
    def update_state(self):
        self.time = time.time()
        self.recharge_battery()
        if self.primary and not self.special: 
            self.fire()
        #self.updateSpecial
        if self.engines:
            self.thrust()
