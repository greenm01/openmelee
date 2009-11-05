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
from engine import draw_solid_polygon, vforangle, rotate
from physics import *
from primary_weapon import PrimaryWeapon
from ship import Ship

class KzerZa(Ship):

    name = "Kzer-Za"
    parts = ["bridge", "body", "tail_left", "tail_right", "rightStrut", "leftStrut", "rightWing", "leftWing"]
    center_part = "bridge"
    scale = 0.0075

    # Ship characteristics
    engineForce = 0, -500
    turnForce = 0, 9000
    rightTurnPoint = -0.5, 0
    leftTurnPoint = 0.5, 0

    # Physics properties
    initial_position = Vec2(30, 30)
    initial_velocity = Vec2(0, 0)
    initial_ang_vel = 0
    density = 5.0
    
    health = 42
    health_capacity = 42
    battery = 42
    battery_capacity = 42
    pEnergy = 8
    sEnergy = 6
    
    pDelay = 0.1    # Primary delay
    sDelay = 0.5    # Secondary delay
    bDelay = 0.05   # Batter recharge rate
    
    def __init__(self, melee):
        super(KzerZa, self).__init__(melee)
            
    def fire(self):
        return
        if not self.primary_time() or self.battery <= self.pEnergy:
            return  
        
        # Drain battery
        self.battery_cost(self.pEnergy)
        
        verts = (31.25, 50), (31.25, -50), (-31.25, -50), (-31.25, 50)
        mass = 10
        inertia = pymunk.moment_for_poly(mass, verts)

        # Create body and shape
        shell = pymunk.Body(mass, inertia) 
        angle = self.body.angle
        shell.angle = angle 
        velocity = 0.0, -10000.0
        rotate(velocity, angle * 57.3)
        shell.velocity = velocity
        shell.position = self.body.local_to_world(Vec2(0, -500))
        poly = pymunk.Poly(shell, verts)

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
        green = 0, 255, 0
        pos = self.body.position
        vec = vforangle(self.body.angle)
        for s in self.body.shapes:
            verts = []
            for v in s.vertices:
                p = rotate(vec, (v.x, v.y))
                px = pos.x + p[0]
                py = pos.y + p[1]
                verts.append((px, py))
            draw_solid_polygon(verts, green, green)        