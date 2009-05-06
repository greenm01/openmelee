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
 
 import flash.display.Sprite;
 import phx.Body;
 import phx.Vector;
 import phx.World;
 import phx.Properties;
 
 import melee.Melee;
 import render.RenderMelee;

 class GameObject extends Sprite
 {
	
	static var GROUP = 0;
	public var group : Int;
    public var rBody : Body;
    public var world : World;
    public var melee : Melee;
    public var radius : Float;
    public var props : Properties;
    public var state : State;
    public var birthday : Float;
    public var lifetime : Float;
    public var damage : Int;
    public var crewCapacity : Int;
	public var crew : Int;
    public var dead : Bool;
	
    public function new(melee:Melee) {
		super();
		this.melee = melee;
        this.world = melee.world;
		group = GROUP++;
        // Default properties
        var linearFriction = 0.999; 
        var angularFriction = 0.999;
        var biasCoef = 0.1; 
        var maxMotion = 1e6; 
        var maxDist = 0.05;
        props = new Properties(linearFriction, angularFriction, biasCoef, maxMotion, maxDist );
        state = new State();
        birthday = flash.Lib.getTimer() * 0.001;
        lifetime = phx.Const.FMAX;
        damage = 5;
        crew = crewCapacity = 2147483648;
		dead = false;
		radius = 0.0;
		melee.gameObjects.addChild(this);
    }
	
	inline function init() {
		rBody.object = this;
		x = rBody.x;
		y = rBody.y;
		rotation = rBody.a * 57.2957795;
		calcRadius();
	}
	
	public function updateState() {
		state.pos.set(rBody.x, rBody.y);
		state.linVel = rBody.v;
	}
    
    public inline function checkDeath() {
        var time = flash.Lib.getTimer() * 0.001;
        var dt = time - birthday;
        if (dt >= lifetime) {
			destroy();
			dead = true;
			melee.destroyList.set(rBody);
			return true;
        } else {
			return false;
		}
    }
    
    public function applyDamage(damage:Int) {
		crew -= damage;
		if (crew <= 0) {
			destroy();
			dead = true;
			melee.destroyList.set(rBody);
		} 
	}
	
	function calcRadius() {
		for (s in rBody.shapes) {
			if (s.type == phx.Shape.CIRCLE) {
				if (s.r > radius) radius = s.r;
			} else {
				// Polygon
				var poly : phx.Polygon = cast(s);
				var v = poly.verts;
				while (v != null) {
					var l = v.length();
					if (l > radius) radius = l;
					v = v.next;
				}
			}
		}
		state.radius = radius;
	}
	
	public function draw(color:Int) {
		RenderMelee.drawBody(graphics, rBody, color);
	}
	
    public function limitVelocity() { }
	function destroy() { }
	function uponDeath() {}
    public function applyGravity() {}
	public function turnRight() {}
	public function turnLeft() {}
	public function thrust() {}
	public function updateAI() {}	
	public function collect(o:GameObject) { }
 }
 
class State
{
	public var pos : Vector;
    public var linVel : Vector;
    public var up : Vector;
    public var side : Vector;
    public var forward : Vector;
    public var target : Vector;
    public var avoid : Vector;
	public var speed : Float;
	public var maxForce : Float;
    public var radius : Float;
	public var enemyAngle : Float;
    public var turn : Bool;
    public var enemy : Ship;

    public function new() {
        pos = Vector.init();
        linVel = Vector.init();
        forward = Vector.init();
		target = Vector.init();
        radius = 0.0;
        speed = 0.0;
    }
    
	public inline function predictFuturePosition(dt : Float) {
        var futPos = pos.clone();
        futPos.x += linVel.x*dt;
        futPos.y += linVel.y*dt;
	    return futPos;
    }
}
