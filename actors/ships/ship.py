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
