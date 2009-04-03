/*
 * Copyright (c) 2009, Mason Green (zzzzrrr)
 * http://www.dsource.org/projects/openmelee
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
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package ai;

import tango.util.container.LinkedList : LinkedList;
import tango.io.Stdout : Stdout;
import tango.math.Math : atan2, abs, PI, isNaN;

import blaze.common.bzMath: bzVec2, bzClamp;
import blaze.bzWorld : bzWorld;

import openmelee.ai.steer : Steer;
import openmelee.ships.ship : Ship;

alias LinkedList!(Ship) ObjectList;

typedef Threat = {
    Ship target;
    bzVec2 steering;
    float distance = 0.0f;
    float collisionTime = 0.0f;
    float minSeparation = float.max;
    bzVec2 relativePos;
    bzVec2 relativeVel;
}

class AI {

	var steer : Steer;
	var ship : Ship;
	var maxPredictionTime : Float= 0.1f;
	var st : Vector;
    
    var avoidRight : Bool;
    var avoidLeft : Bool;
    
	public function new(ship : Ship, objectList : FastList<Ship>) {
		this.ship = ship;
		steer = new Steer(ship, objectList);
	}
	
    // Elementary steering AI 
	void move(Ship enemy) {
	   
        if(!ship) return;
        
        Threat threat;        
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
