/*
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
 * * Neither the name of the polygonal nor the names of its contributors may be
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

import phx.Vector;
import phx.World;

import ships.Ship;
import ships.GameObject;

typedef Threat = {
    var target : Ship;
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
	var ship : Ship;
	var maxPredictionTime : Float;
	var st : Vector;
    
    var avoidRight : Bool;
    var avoidLeft : Bool;
    
	public function new(ship : Ship, objectList : FastList<GameObject>) {
		this.ship = ship;
		steer = new Steer(ship, objectList);
        maxPredictionTime = 0.1;
	}
	
    // Elementary steering AI 
	public function move(enemy:Ship) {
	   
        if(!ship) return;
        
        var threat : Threat = {target:Enemy, steering:Vector.init(), distance:0.0, collisionTime:0.0, 
                                minSeparation:0.0, relativePos:Vector.init(), relativeVel:Vector.inig()}; 
	    steer.update();
        steer.collisionThreat(threat);
        st = threat.steering;
        
        if(st == bzVec2.zeroVect) {
            if(avoidLeft || avoidRight) {
                avoidLeft = avoidRight = false;
                ship.rBody.angularVelocity = 0.0f;
            }
            st = steer.targetEnemy(enemy.state, maxPredictionTime);
            chase(enemy);
            return;
        } else {
            ship.state.turn = false;
            avoid();
            return;
        }
        
        assert(0);
    }
    
    void chase(Ship enemy) {
        
        ship.state.target = st;
        st = ship.rBody.localPoint(st);
        // Because ship's heading is 90 off rigid body's heading
        st = st.rotateLeft90();
        float angle = atan2(st.x, st.y);
        
		if(abs(angle) > 0.05) {
            if(!ship.state.turn) {
                if(st.x >= 0) {
                    ship.turnRight();
                    ship.state.turn = true;
                } else {
                    ship.state.turn = true;
                    ship.turnLeft();
                }
           }
		} else {
			ship.rBody.angularVelocity = 0.0f;
			ship.state.turn = false;
		}
		
		float range = (ship.state.position - enemy.state.position).length; 
		if(range > 2 && abs(angle) < PI/4) {
			ship.thrust();
		}
    }
    
    void avoid() {
        
        st = ship.rBody.localPoint(st);
        // Because ship's heading is 90 off rigid body's heading
        st = st.rotateLeft90();
        float angle = atan2(st.x, st.y);
        
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
