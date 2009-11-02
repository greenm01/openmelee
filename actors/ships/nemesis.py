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
from physics import Vec2

from ship import Ship

class Nemesis(Ship):
    name = "Nemesis"
    parts = "B1 B2 B3 R1 R2 R3 R4 R5 L1 L2 L3 L4 L5".split()
    center_part = "B1"
    scale = 0.001
    
    # Ship characteristics
    engineForce = 0, -500
    turnForce = 0, 5000
    rightTurnPoint = -0.5, 0
    leftTurnPoint = 0.5, 0

    # Physics properties
    initial_position = Vec2(-10, -10)
    initial_velocity = Vec2(0, 0)
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
    
    def __init__(self, melee):
        super(Nemesis, self).__init__(melee)