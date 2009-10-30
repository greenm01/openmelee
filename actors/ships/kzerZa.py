import random
from math import pi

import pymunk as pm
from pymunk.util import *
from pymunk import Vec2d

from ship import Ship
from utils import squirtle
from primary_weapon import PrimaryWeapon

class KzerZa(Ship):
    
    def __init__(self, melee):
        Ship.__init__(self, melee)
        
        self.melee = melee
        self.group = id(self)
        
        # Ship characteristics
        self.engineForce = Vec2d(0, -6000)
        self.turnForce = Vec2d(0, 200000)
        self.rightTurnPoint = Vec2d(-200, 0)
        self.leftTurnPoint = Vec2d(200, 0)
        
        self.health = 42
        self.health_capacity = 42
        self.battery = 42
        self.battery_capacity = 42
        self.pEnergy = 8
        self.sEnergy = 6
        
        # Primary delay
        self.pDelay = 0.1
        # Secondary delay
        self.sDelay = 0.5
        # Batter recharge rate
        self.bDelay = 0.05
        
        # Load SVG file
        file = "data/ships/Kzer-Za.svg"
        self.svg = squirtle.SVG(file, anchor_x='center', anchor_y='center')
        
        parts = "bridge", "body", "tail", "rightStrut", "leftStrut", "rightWing", "leftWing"
        poly_lines = list(self.svg.shapes[part] for part in parts)
        
        # Calculate intertia and translate points
        mass = 1
        translate = calc_center(poly_lines[1])
        
        inertia = 0
        for p in poly_lines:
            for v in p: v -= translate
            inertia += pm.moment_for_poly(mass, p) 
        
        self.body = pm.Body(mass, inertia) 
        self.body.position = (900, 1000)
        
        self.shapes = []
        for p in poly_lines:
            self.shapes.append(pm.Poly(self.body, p))
        
        melee.space.add(self.body, self.shapes) 
        
    def fire(self):
        if not self.primary_time() or self.battery <= self.pEnergy:
            return  
        
        # Drain battery
        self.battery_cost(self.pEnergy)
        
        verts = (31.25, 50), (31.25, -50), (-31.25, -50), (-31.25, 50)
        mass = 10
        inertia = pm.moment_for_poly(mass, verts)

        # Create body and shape
        shell = pm.Body(mass, inertia) 
        angle = self.body.angle
        shell.angle = angle 
        velocity = Vec2d(0.0, -10000.0)
        velocity.rotate(angle * 57.3)
        shell.velocity = velocity
        shell.position = self.body.local_to_world(Vec2d(0, -500))
        poly = pm.Poly(shell, verts)

        #Add to space
        self.melee.space.add(shell, poly) 
        
        # Create projectile
        projectile = PrimaryWeapon(self, self.melee, shell)
        projectile.group = self.group
        projectile.lifetime = 2.5
        projectile.damage = 10
        projectile.health = 5
        projectile.shapes = [poly]
        
    def draw(self):
        
        x = self.body.position.x
        y = self.body.position.y
        # convert to degrees
        a = (self.body.angle * 57.3) + 180
        
        self.svg.draw(x, y, angle = a)
        
        #self.debugDraw()
