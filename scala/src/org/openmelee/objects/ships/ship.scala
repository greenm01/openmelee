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
package org.openmelee.objects.ships;

import org.villane.box2d.dynamics.World
import org.villane.box2d.shapes.Shape
import org.villane.box2d.shapes.Polygon
import org.villane.vecmath.Vector2f

import org.openmelee.objects.GameObject
//import utils.Util;
import org.openmelee.melee.Melee
//import ai.AI;

abstract class Ship(melee:Melee) extends GameObject
{

    var name : String = _
	var captain : String = _
	//var primeWep : GameObject = _
	//var secondWep : GameObject = _

    protected var engineForce : Vector2f = _
    protected var turnForce : Vector2f = _
    protected var leftTurnPoint : Vector2f = _
    protected var rightTurnPoint : Vector2f = _

    // Control commands
    var turnL : Boolean = _
    var turnR : Boolean = _
    var engines : Boolean = _
    var special : Boolean = _
	var primary : Boolean = _
	
	// Timing parameters (seconds)
	var time : Float = _
    // Primary delay
	var pDelay : Float = _
	// Secondary delay
	var sDelay : Float = _
	// Primary time
	var pTime : Float = _
	// Secondary time
	var sTime : Float = _
	// Battery refresh delay
	var bDelay : Float = _
	// Battery time
	var bTime : Float = _

    var crewCapacity : Int = _
    var crew : Int = _
    
	var batteryCapacity : Int = 0
	var battery : Int = 0

	// Primary battery cost
	protected var pEnergy : Int = _
	// Secondary battery cost
	protected var sEnergy : Int = _

    private var maxLinVel : Float = 35
    private var maxAngVel : Float = 2

	//private var ai : AI;
	private var enemy : Ship = null

    @inline def thrust() {
        body.force += engineForce
    }

    @inline def turnLeft() {
        body.torque += leftTurnPoint cross turnForce
    }

    @inline def turnRight() {
        body.torque += rightTurnPoint cross turnForce
    }

    /*
    def limitVelocity() {
        var vx = body.v.x;
        var vy = body.v.y;
        var omega = body.w;
        body.v.x = Util.clamp(vx, -maxLinVel, maxLinVel);
        body.v.y = Util.clamp(vy, -maxLinVel, maxLinVel);
        body.w = Util.clamp(omega, -maxAngVel, maxAngVel);
    }

    def updateState() {
		time = flash.Lib.getTimer() * 0.001;
		rechargeBattery();
		if (primary && !special) {
			fire();
		}
		updateSpecial();
        if(engines) {
            thrust();
        }
        state.linVel.set(body.v.x, body.v.y);
        state.speed = state.linVel.length();
        state.pos.x = body.x;
        state.pos.y = body.y;
        state.forward = engineForce.rotate(body.a);
    }

	def initAI(enemy:Ship) {
		ai = new AI(this, melee.gameObjects);
		this.enemy = ai.enemy = enemy;
	}

	def updateAI() {
		if(ai != null) {
			ai.move();
		}
	}

    def destroy() {
        for(s in body.shapes) {
            var debris = new Debris(melee);
            switch(s.type) {
                case Shape.POLYGON:
                    var verts = new Array<Vector2f>();
                    var v = s.polygon.verts;
                    while(v != null) {
                        verts.push(v.clone());
                        v = v.next;
                    }
                    var pos = new Vector2f(body.x, body.y);
                    debris.initPoly(verts, pos, s.offset);
                case Shape.CIRCLE:
            }
        }
    }

    def applyGravity() {
        var minRadius = 0.1;
        var maxRadius = 50.0;
        var strength = 75.0;
        var center = new Vector2f(400.0, 250.0);

        var rx = center.x - body.x;
        var ry = center.y - body.y;

        var d = Math.sqrt(rx * rx + ry * ry);
        if (d < 1e-7)
            return;
        else {
            rx /= d;
            ry /= d;
        }

        var ratio = (d - minRadius) / (maxRadius - minRadius);
        if (ratio < 0)
            ratio = 0;
        else
            if (ratio > 1)
                ratio = 1;

        body.f.x += rx * ratio * strength;
        body.f.y += ry * ratio * strength;

    }

	def primaryTime() {
		var dt = time - pTime;
		if(dt >= pDelay) {
			pTime = time;
			return true;
		} else {
			return false;
		}
	}

	def rechargeBattery() {
		var dt = time - bTime;
		if(dt >= bDelay && battery < batteryCapacity) {
			bTime = time;
			battery += 1;
		}
	}

	def batteryCost(cost:Int) {
		var b = battery - cost;
		battery = cast(Util.clamp(b, 0, batteryCapacity), Int);
	}
    */

	def updateSpecial
    def fire
}
