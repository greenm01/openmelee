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
import org.villane.vecmath.MathUtil

import org.openmelee.objects.GameObject
import utils.Util;
import org.openmelee.melee.Melee
//import ai.AI;

abstract class Ship(melee:Melee) extends GameObject
{

    var name : String = _
	var captain : String = _
	var primeWep : GameObject = _
	var secondWep : GameObject = _

    protected var engineForce : Vector2f = _
    protected var turnForce : Vector2f = _
    protected var leftTurnPoint : Vector2f = _
    protected var rightTurnPoint : Vector2f = _

    // Control commands
    var turnL  = false
    var turnR  = false
    var engines = false
    var special = false
	var primary = false
	
	// Timing parameters (seconds)
	var time = System.currentTimeMillis * 0.001f
    // Primary delay
	var pDelay = 0f
	// Secondary delay
	var sDelay = 0f
	// Primary time
	var pTime = 0f
	// Secondary time
	var sTime = 0f
	// Battery refresh delay
	var bDelay = 0f
	// Battery time
	var bTime = 0f

    var crewCapacity : Int = _
    var crew : Int = _
    
	var batteryCapacity : Int = _
	var battery : Int = _

	// Primary battery cost
	protected var pEnergy : Int = _
	// Secondary battery cost
	protected var sEnergy : Int = _

    private var maxLinVel  = new Vector2f(35,35)
    private var maxAngVel : Float = 2

	//private var ai : AI;
	private var enemy : Ship = null

    @inline def thrust() {
        body.force += Util.rotate(engineForce, body.angle)
    }

    @inline def turnLeft() {
        body.torque += leftTurnPoint cross turnForce
    }

    @inline def turnRight() {
        body.torque += rightTurnPoint cross turnForce
    }

    @inline def limitVelocity() {
        val v = body.linearVelocity
        body.linearVelocity = v.clamp(-maxLinVel, maxLinVel)
        val omega = body.angularVelocity
        body.angularVelocity = MathUtil.clamp(omega, -maxAngVel, maxAngVel)
    }

    @inline override def updateState() {
		time = System.currentTimeMillis * 0.001f
		rechargeBattery
		if (primary && !special) fire
		updateSpecial
        if(engines) thrust
    }

    /*
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
    */

    @inline def applyPlanetGravity() {

        val minRadius = 0.1f
        val maxRadius = 50f
        val strength = 75f

        // TODO: Correct center
        val center = new Vector2f(400f, 250f)
        var r = center - body.pos
        val d = Math.sqrt(r.x * r.x + r.y * r.y).toFloat
        r /= d
        var ratio = (d - minRadius) / (maxRadius - minRadius)

        if (ratio < 0)
            ratio = 0f
        else if (ratio > 1)
            ratio = 1f

        body.force += r * ratio * strength
    }

	@inline def primaryTime = {
		var dt = time - pTime
		if(dt >= pDelay) {
			pTime = time
			true
		} else {
			false
		}
    }

	@inline def rechargeBattery() {
		var dt = time - bTime
		if(dt >= bDelay && battery < batteryCapacity) {
			bTime = time
			battery += 1
		}
	}

	@inline def batteryCost(cost:Int) {
		var b = battery - cost
		battery = MathUtil.clamp(b.toFloat, 0f, batteryCapacity.toFloat).toInt
	}
    
	def updateSpecial
    def fire
}
