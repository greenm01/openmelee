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
from math import pi as PI

from physics import Vec2, Circle, Body, Polygon
from ship import *
from secondary_weapon import SecondaryWeapon
from primary_weapon import PrimaryWeapon

class Nemesis(Ship):

    name = "Nemesis"
    parts = "B1 B2 B3 R1 R2 R3 R4 R5 L1 L2 L3 L4 L5".split()
    center_part = "B1"
    scale = 0.0075
    
    # Ship characteristics
    engineForce = 0, 30
    turnForce = 0, 5000
    rightTurnPoint = -2.5, 0
    leftTurnPoint = 2.5, 0

    # Physics properties
    initial_position = Vec2(-10, -10)
    initial_velocity = Vec2(-10, 15)
    initial_ang_vel = 0.75
    density = 5
    
    health = 16
    health_capacity = 16
    battery = 20
    battery_capacity = 20
    pEnergy = 5
    sEnergy = 6

    # Recharge rates
    pDelay = 0.15
    sDelay = 0.5
    bDelay = 0.25
    
    # Debug draw colors 
    fill = 42, 38, 127
    outline = 42, 38, 127
    
    turret_angle = -PI * 0.5
    
    def __init__(self, melee):
        Ship.__init__(self, melee, -1)
        self.group = -1
        # Create body
        bodydef = Body()
        bodydef.ccd = True
        bodydef.position = self.body.position 
        self.turret = melee.world.append_body(bodydef)
        self.turret.angular_velocity = self.body.angular_velocity
        self.turret.linear_velocity = self.body.linear_velocity
        
        # Create shapes
        self.radius = 0.85
        density = 2.0
        # Base
        base = Circle()
        base.collision_group = self.group
        base.radius = self.radius 
        base.density = density
        # Barrel
        verts = [Vec2(0.15, 2), Vec2( -0.15, 2), Vec2(-0.15, 0), Vec2(0.15, 0)]
        barrel = Polygon()
        barrel.vertices = verts
        barrel.collision_group = self.group
        barrel.density = density
        
        self.turret.append_shape(base)
        self.turret.append_shape(barrel)
        self.turret.set_mass_from_shapes()
       
		# Create turret
        SecondaryWeapon(self, melee, self.turret);
    
    def fire(self):
        
        if not self.primary_time() or self.battery <= self.pEnergy:
            return  
        
        # Drain battery
        self.battery_cost(self.pEnergy)
        
        # Create body and shape
        bodydef = Body()
        bodydef.ccd = True
        bodydef.angle = self.body.angle + (PI * 0.5) + self.turret_angle
        bodydef.position = self.turret.get_world_point(Vec2(0, 3))
        shell = self.melee.world.append_body(bodydef)
        angle = vforangle(bodydef.angle)
        velocity = rotate(angle, (0.0, 150.0))
        vb = self.body.linear_velocity
        shell.linear_velocity = Vec2(velocity[0]+vb.x, velocity[1]+vb.y)
        
        polydef = Polygon()
        verts = [Vec2(0.5, 0.8), Vec2(-0.5, 0.8), Vec2(-0.5, -0.8), Vec2(0.5, -0.8)]
        polydef.vertices = verts
        polydef.density = 5
        polydef.collision_group = self.group
        
        shell.append_shape(polydef)
        shell.set_mass_from_shapes()
        
        # Create projectile
        projectile = PrimaryWeapon(self, self.melee, shell)
        projectile.group = self.group
        projectile.lifetime = 2.5
        projectile.damage = 10
        projectile.health = 5
        projectile.shapes = verts 
        
    def update_special(self):
    
        # Update turret state
        self.turret.position = self.body.position
        self.turret.angular_velocity = self.body.angular_velocity
        self.turret.linear_velocity = self.body.linear_velocity
        
        # Adjust turret angle
        if(self.buttons & SPECIAL):
            if(self.buttons & LEFT):
                self.turret_angle += PI / 32
            if(self.buttons & RIGHT):
                self.turret_angle -= PI / 32
                
        self.turret.angle = self.body.angle + (PI * 0.5) + self.turret_angle
        