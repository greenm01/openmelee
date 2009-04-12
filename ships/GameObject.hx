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
 package ships;
 
 import phx.Body;
 import phx.Vector;
 import phx.World;
 import phx.Properties;
 
 import melee.Melee;
 
 class GameObject
 {
    public var rBody : Body;
    public var world : World;
    public var melee : Melee;
    public var radius : Float;
    public var props : Properties;
    public var state : State;
    public var birthday : Float;
    public var lifetime : Float;
    public var damage : Float;
    public var health : Float;
    
    public function new(melee:Melee) {
        if(melee != null) {
            this.world = melee.world;
        }
        this.melee = melee;
        // Default properties
        var linearFriction = 0.999; 
        var angularFriction = 0.999;
        var biasCoef = 0.1; 
        var maxMotion = 1e6; 
        var maxDist = 0.05;
        props = new Properties(linearFriction, angularFriction, biasCoef, maxMotion, maxDist );
        state = new State();
        birthday = neko.Sys.time();
        lifetime = phx.Const.FMAX;
        damage = 5.0;
        health = phx.Const.FMAX;
    }
    
    public inline function checkDeath() {
        var time = neko.Sys.time();
        var dt = time - birthday;
        if(dt >= lifetime) {
            return true;
        } else {
            return false;
        }
    }
    
    public function destroy() {
        return false;    
    }
    
    public function limitVelocity(){}
    public function updateState() {}
    public function applyGravity() {}
    
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
