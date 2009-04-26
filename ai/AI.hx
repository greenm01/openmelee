/* OpenMelee
 * Copyright (c) 2009, Mason Green 
 * http://github.com/zzzzrrr/openmelee
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of OpenMelee nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package ai;

import haxe.FastList;

import phx.Vector;
import phx.World;

import ships.Ship;
import ships.GameObject;

typedef Threat = {
    var target : GameObject;
    var steering : Vector;
    var distance : Float;
    var collisionTime : Float;
    var minSeparation : Float;
    var relativePos : Vector;
    var relativeVel : Vector;
}

class AI 
{

	var steer : Steer;
	public var enemy : Ship;
	public var ship : GameObject;
	var maxPredictionTime : Float;
	var st : Vector;
    var range : Float;
	
	public function new(ship : GameObject, objectList : FastList<GameObject>) {
		this.ship = ship;
		steer = new Steer(ship, objectList);
        maxPredictionTime = 0.25;
	}
	
    // Elementary steering AI 
	public function move() {

        var threat : Threat = {target:null, steering:Vector.init(), distance:0.0, collisionTime:0.0, 
                                minSeparation:phx.Const.FMAX, relativePos:Vector.init(), relativeVel:Vector.init()}; 
	    steer.update(); 
        st = steer.collisionThreat(threat, 2.0);
       		
		range = (ship.state.pos.minus(enemy.state.pos)).length();
		var range2 = (ship.state.pos.minus(ship.melee.planet.state.pos)).length(); 
        var margin = ship.melee.planet.radius + ship.radius*2.0;

		if(st == null && range2 > margin) {
            chase();
            return;
        } else {
			if(st != null) {
            	avoid();
			}
            return;
        }
    }
    
    function chase() {
        
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
    }
    
    function avoid() {

		var k = ship.rBody.localPoint(st);
		k = k.rotateLeft90();
		var angle = Math.atan2(k.x, k.y);
        var t = ship.state.linVel.cross(st);

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
	
    }

}
