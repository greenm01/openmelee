import random
import pymunk as pm
from pymunk.util import *
from pymunk import Vec2d

from ship import Ship
from utils import squirtle

class Nemesis(Ship):
    
    def __init__(self, melee):
        Ship.__init__(self, melee)
        
        # Ship characteristics
        self.engineForce = Vec2d(0, -6000)
        self.turnForce = Vec2d(0, 200000)
        self.rightTurnPoint = Vec2d(-200, 0)
        self.leftTurnPoint = Vec2d(200, 0)
        
        self.health = 16
        self.health_capacity = 16
        self.battery = 20
        self.battery_capacity = 20
        self.pEnergy = 5
        self.sEnergy = 6

        # Recharge rates
        self.pDelay = 0.15
        self.sDelay = 0.5
        self.bDelay = 0.25
        
        # Load SVG file
        file = "data/ships/Nemesis.svg"
        self.svg = squirtle.SVG(file, anchor_x='center', anchor_y='center')
        
        parts = "B1 B2 B3 R1 R2 R3 R4 R5 L1 L2 L3 L4 L5".split()
        polyLines = list(self.svg.shapes[part] for part in parts)
        
        # Calculate intertia and translate points
        mass = 1
        translate = calc_center(polyLines[0])
        
        inertia = 0
        for p in polyLines:
            for z in p: z -= translate
            inertia += pm.moment_for_poly(mass, p) 
        
        # Create body
        self.body = pm.Body(mass, inertia) 
        self.body.position = (-900, -3000)
        self.body.velocity = (-4000, -500)
        self.body.angular_velocity = 0.75
        
        # Create shapes
        self.shapes = []
        for p in polyLines:
            self.shapes.append(pm.Poly(self.body, p))
        
        melee.space.add(self.body, self.shapes) 
                                   
    def draw(self):
        
        x = self.body.position.x
        y = self.body.position.y
        # convert to degrees
        a = (self.body.angle * 57.3) + 180
        
        self.svg.draw(x, y, angle = a)

        #self.debugDraw()

