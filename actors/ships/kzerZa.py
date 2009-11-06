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
    center_part = "body"
    scale = 0.0075

    # Ship characteristics
    engineForce = 0, -50
    turnForce = 0, 8000
    rightTurnPoint = -2.0, 0
    leftTurnPoint = 2.0, 0

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
    
    # Debug draw colors 
    fill = 0, 255, 0
    outline = 0, 255, 0
    
    def __init__(self, melee):
        super(KzerZa, self).__init__(melee)
            
    def fire(self):
        
        if not self.primary_time() or self.battery <= self.pEnergy:
            return  
        
        # Drain battery
        self.battery_cost(self.pEnergy)
        
        # Create body and shape
        bodydef = Body()
        bodydef.ccd = True
        bodydef.angle = self.body.angle
        bodydef.position = self.body.get_world_point(Vec2(0, -5))
        shell = self.melee.world.append_body(bodydef)
        angle = vforangle(self.body.angle)
        velocity = rotate(angle, (0.0, -100.0))
        shell.linear_velocity = Vec2(velocity[0], velocity[1])
        
        polydef = Polygon()
        verts = [Vec2(0.5, 0.8), Vec2(-0.5, 0.8), Vec2(-0.5, -0.8), Vec2(0.5, -0.8)]
        polydef.vertices = verts
        polydef.density = 5
        
        shell.append_shape(polydef)
        shell.set_mass_from_shapes()
        
        # Create projectile
        projectile = PrimaryWeapon(self, self.melee, shell)
        projectile.group = self.group
        projectile.lifetime = 2.5
        projectile.damage = 10
        projectile.health = 5
        projectile.shapes = verts    