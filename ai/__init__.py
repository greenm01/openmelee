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
from math import atan2

class Threat(object):

    target = None
    steering  = None
    distance = 0.0
    collision_time = 1e308
    min_separation = 1e308
    relative_position = None
    relative_velocity = None


class AI(object):

    def __init__(self, ship, actors):
        self.ship = ship
        self.steer = Steer(ship, actors)
        self.max_prediction_time = 0.25

    // Elementary steering AI 
    def move(self):

        threat = (Nil, Vector.init(), 0.0, 0.0, phx.Const.FMAX, Vector.init(), 
                      Vector.init())
                      
        self.update() 
        st = self.steer.collisionThreat(threat, 2.0)
            
        range = (ship.body.position - enemy.body.position).length()
        range2 = (ship.body.position - ship.melee.planet.body.position).length()
        margin = ship.melee.planet.radius + ship.radius * 2.0

        if st == Nil and range2 > margin:
            self.chase()
            return
        
        if st != Nil:
            self.avoid()
			
    
    def __chase(self):
        
		st = steer.target(enemy.state, maxPredictionTime);
        st = ship.rBody.localPoint(st);
        // Because ship's heading is 90 off rigid body's heading
        st = st.rotateLeft90();
        var angle = Math.atan2(st.x, st.y);
    	var angle2 = Math.abs(angle);

		if(range < 50 && angle2 < Math.PI/8.0) {
			var s : Ship = cast(ship);
			s.fire();
		}

		if(angle2 > 0.05) {
        	if(angle >= 0.0) {
            	ship.turnRight();
         	} else {
            	ship.turnLeft();
            }
		} else {
			ship.rBody.w = 0.0;
			if(range > 5.0) {
				ship.thrust();
			} 
		}
    
    def __avoid(self):

		k = ship.rBody.localPoint(st)
		k.rotateLeft90()
		var angle = Math.atan2(k.x, k.y)
        var t = ship.state.linVel.cross(st)

		angle = Math.abs(angle);
		if(range < 50 && angle < Math.PI/8.0) {
			var s : Ship = cast(ship);
			s.fire();
		}

        if(t >= 0) {
        	ship.turnRight();
        } else {
            ship.turnLeft();
        }

		ship.thrust();

