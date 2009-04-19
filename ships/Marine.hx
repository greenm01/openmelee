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
package ships;

import phx.Vector;

import melee.Melee;
import ai.Steer;

// Autonomous Space Marine - Ooh-rah!
class Marine extends GameObject
{
	// The ship this Jarhead deploys from
	var ship : Ship;
	// The enemy to kill
	var enemy : Ship;
	
	var steer : Steer;
	var maxPredictionTime : Float;
	
	var engineForce : Vector;
	var turnForce : Vector;
	var rightTurnPoint : Vector;
	var leftTurnPoint : Vector;
	
	public function new(melee:Melee, ship:Ship) {
		super(melee);
		this.ship = ship;
		enemy = melee.ship2;
		steer = new Steer(this, melee.objectList);
		maxPredictionTime = 0.1;
		engineForce = new Vector(10, 0);
        turnForce = new Vector(0, 10);
        rightTurnPoint = new Vector( -0.15, 0);
		leftTurnPoint = new Vector(0.15, 0);
	}
	
	public override function updateState() {
	 	state.linVel.set(rBody.v.x, rBody.v.y);
        state.speed = state.linVel.length();
        state.pos.x = rBody.x;
        state.pos.y = rBody.y;
        state.forward = engineForce.rotate(rBody.a);
		ai();
	}
	
	public override function thrust() {
		var force = engineForce.rotate(rBody.a);
        rBody.f.x += force.x;
        rBody.f.y += force.y;
	}
	
	function ai() {
		steer.update();
	   	var target = steer.targetEnemy(enemy.state, maxPredictionTime);
		var v = steer.steerForSeek(target);
		rBody.v.x = v.x;
		rBody.v.y = v.y;
	}
	
	public override function turnLeft() {
    }

    public override function turnRight() {
    }
	
}
