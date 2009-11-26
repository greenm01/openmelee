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
from math import atan2, pi
from steer import Steer

class AI(object):

    def __init__(self, ship, enemy, actors):
        self.ship = ship
        self.steer = Steer(ship, actors)
        self.max_prediction_time = 0.25
        self.planet = ship.melee.planet
        self.enemy = enemy

    # Elementary steering AI 
    def update(self):
        pass              
        #self.update() 
        st = None #self.steer.collision_threat(2.0)
            
        range = (self.ship.body.position - self.enemy.body.position).length
        range2 = (self.ship.body.position - self.planet.body.position).length
        margin =  self.planet.radius + self.ship.radius * 2.0

        if st == None and range2 > margin:
            self.chase()
            return
        
        #if st != None:
        #    self.avoid()
			
    def chase(self):

        st = self.steer.target(self.enemy, self.max_prediction_time)
        st = self.ship.body.get_local_point(st)
        # Because ship's heading is 90 off rigid body's heading
        #st = st.rotateLeft90();
        angle = atan2(st.x, st.y)
        angle2 = abs(angle)

        if range < 50 and angle2 < pi/8.0:
            self.ship.fire()

        if angle2 > 0.05:
            if angle >= 0.0:
                self.ship.turn_right()
            else:
                self.ship.turn_left()
        else:
            self.ship.body.angular_velocity = 0.0
            if range > 5.0:
                self.ship.thrust()
        
    def avoid(self):
        pass
        '''
        k = self/ship.body.localPoint(st)
        #k.rotateLeft90()
        angle = atan2(k.x, k.y)
        t = self.ship.linear_velocity.cross(st)

        angle = abs(angle)
        if range < 50 and angle < pi/8.0:
            self.ship.fire()

        if t >= 0:
            self.ship.turn_right()
        else:
            self.ship.turn_left()

        ship.thrust()
        '''
