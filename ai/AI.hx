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
    
    var avoidRight : Bool;
    var avoidLeft : Bool;
    var range : Float;
	
	public function new(ship : GameObject, objectList : FastList<GameObject>) {
		this.ship = ship;
		steer = new Steer(ship, objectList);
        maxPredictionTime = 0.25;
        avoidLeft = avoidRight = false;
	}
	
    // Elementary steering AI 
	public function move() {

        if(ship == null) return;
        
        var go = new GameObject(null);
        var threat : Threat = {target:go, steering:Vector.init(), distance:0.0, collisionTime:0.0, 
                                minSeparation:0.0, relativePos:Vector.init(), relativeVel:Vector.init()}; 
	    steer.update();
        steer.collisionThreat(threat);
        st = threat.steering;
		
		range = (ship.state.pos.minus(enemy.state.pos)).length(); 
		
		if(st.x == 0.0 && st.y == 0.0) {
            if(avoidLeft || avoidRight) {
                avoidLeft = avoidRight = false;
                ship.rBody.w = 0.0;
            }
            st = steer.targetEnemy(enemy.state, maxPredictionTime);
            chase();
            return;
        } else {
            ship.state.turn = false;
            avoid();
            return;
        }
 
        throw "error";
    }
    
    function chase() {
        
        ship.state.target = st.clone();
        st = ship.rBody.localPoint(st);
        // Because ship's heading is 90 off rigid body's heading
        st = st.rotateLeft90();
        var angle = Math.atan2(st.x, st.y);
    
		if(Math.abs(angle) > 0.05) {
            if(!ship.state.turn) {
                if(angle >= 0) {
                    ship.turnRight();
                    ship.state.turn = true;
                } else {
                    ship.state.turn = true;
                    ship.turnLeft();
                }
           }
		} else {
			ship.rBody.w = 0.0;
			ship.state.turn = false;
			if(range > 5.0) {
				ship.thrust();
			}
		}
    }
    
    function avoid() {
       
        st = ship.rBody.localPoint(st);
        // Because ship's heading is 90 off rigid body's heading
        st = st.rotateLeft90();
        var angle = Math.atan2(st.x, st.y);
        
        if(st.x <= 0) {
            if(!avoidRight) {
                ship.turnRight();
                avoidRight = true;
                avoidLeft = false;
            }
        } else {
            if(!avoidLeft) {
                ship.turnLeft();
                avoidLeft = true;
                avoidRight = false;
            }
        }
               
		ship.thrust();
	
    }

}
