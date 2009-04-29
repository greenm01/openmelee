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

import flash.geom.Vector3D;
import haxe.FastList;

import phx.Vector;
import phx.World;
import phx.Shape;
import phx.Body;
import phx.Polygon;

import ships.GameObject;
import utils.Util;
import melee.Melee;
import ai.AI;

class Ship extends GameObject
{
    
	public var name : String;
	public var captain : String;
	
    var engineForce : Vector;
    var turnForce : Vector;
    var leftTurnPoint : Vector;
    var rightTurnPoint : Vector;
    
    // Control commands
    public var turnL : Bool;
    public var turnR : Bool;
    public var engines : Bool;
    public var special : Bool;
	public var primary : Bool;
	
	// Timing parameters (seconds)
    // Primary delay
	var pDelay : Float;
	// Secondary delay
	var sDelay : Float;
	// Primary time
	var pTime : Float;
	// Secondary time
	var sTime : Float;

	public var batteryCapacity : Int;
	public var battery : Int;
	public var crewCapacity : Int;
	public var crew : Int;
	
    var maxLinVel : Float;
    var maxAngVel : Float;

	var ai : AI;
	var enemy : Ship;
	
    public function new(melee:Melee) {
        super(melee);
		maxLinVel = 30.0;
		maxAngVel = 2.0;
		pTime = 0.0;
    }

    public override function thrust() {
        var force = engineForce.rotate(rBody.a);
        rBody.f.x += force.x;
        rBody.f.y += force.y;
    }

    public override function turnLeft() {
        var lp = leftTurnPoint.rotate(rBody.a);
        var tf = turnForce.rotate(rBody.a);
        rBody.t += lp.cross(tf);
    }

    public override function turnRight() {
        var rp = rightTurnPoint.rotate(rBody.a);
        var tf = turnForce.rotate(rBody.a);
        rBody.t += rp.cross(tf);
    }

    public override function limitVelocity() {
        var vx = rBody.v.x;
        var vy = rBody.v.y;
        var omega = rBody.w;
        rBody.v.x = Util.clamp(vx, -maxLinVel, maxLinVel);
        rBody.v.y = Util.clamp(vy, -maxLinVel, maxLinVel);
        rBody.w = Util.clamp(omega, -maxAngVel, maxAngVel);
    }

    public override function updateState() {
		if (primary && !special) {
			fire();
		}
		updateSpecial();
        if(engines) {
            thrust();
        }
        state.linVel.set(rBody.v.x, rBody.v.y);
        state.speed = state.linVel.length();
        state.pos.x = rBody.x;
        state.pos.y = rBody.y;
        state.forward = engineForce.rotate(rBody.a);
    }
	
	public function initAI(enemy:Ship) {
		ai = new AI(this, melee.objectList);
		this.enemy = ai.enemy = enemy;
	}
	
	public override function updateAI() {
		if(ai != null) {
			ai.move();
		}
	}

	public override function applyDamage(damage:Int) {
		crew -= damage;
		if (crew <= 0) {
			destroy();
			return true;
		} else {
			return false;
		}
	}
	
    override function destroy() {
        for(s in rBody.shapes) {
            var debris = new Debris(melee);
            switch(s.type) {
                case Shape.POLYGON:
                    var verts = new Array<Vector>();
                    var v = s.polygon.verts;
                    while(v != null) {
                        verts.push(v.clone());
                        v = v.next;
                    }
                    var pos = new Vector(rBody.x, rBody.y);
                    debris.initPoly(verts, pos, s.offset);
                case Shape.CIRCLE:
            }
        }
		uponDeath();
        world.removeBody(rBody);
		dead = true;
        return;
    }
	
    public override function applyGravity() {
        var minRadius = 0.1;
        var maxRadius = 50.0;
        var strength = 100.0;
        var center = new Vector(400.0, 250.0);
        
        var rx = center.x - rBody.x;
        var ry = center.y - rBody.y;
        
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

        rBody.f.x += rx * ratio * strength;
        rBody.f.y += ry * ratio * strength;
        
    }

	inline function primaryTime() {
		var time = flash.Lib.getTimer() * 0.001;
		var dt = time - pTime;
		if(dt >= pDelay) {
			pTime = time;
			return true;
		} else {
			return false;
		}
	}
	
	public function uponDeath() {}
	public function updateSpecial() {}
    public function fire() {}
}
