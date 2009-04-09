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

import haxe.FastList;

import phx.Vector;
import phx.World;
import phx.Shape;
import phx.Body;

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

	public inline function predictFuturePosition(dt : Float) {
        var futPos = pos.clone();
        futPos.x += linVel.x*dt;
        futPos.y += linVel.y*dt;
	    return futPos;
    }
}

class Ship
{
    var world : World;
    public var rBody : Body;
    var shapeList : FastList<Shape>;
    var engineForce : Vector;
    var turnForce : Vector;
    var leftTurnPoint : Vector;
    var rightTurnPoint : Vector;
	var state : State;
    var battery : Float;
    var crew : Float;
    var maxLinVel : Float;
    var maxAngVel : Float;

    public function new(world : World) {
        this.world = world;
        shapeList = new FastList();
    }

    public function thrust() {
        var force = engineForce.rotate(rBody.a);
        rBody.f.x += force.x;
        rBody.f.y += force.y;
    }

    public inline function turnLeft() {
        var lp = leftTurnPoint.rotate(rBody.a);
        var tf = turnForce.rotate(rBody.a);
        rBody.t += lp.cross(tf);
    }

    public inline function turnRight() {
        var rp = rightTurnPoint.rotate(rBody.a);
        var tf = turnForce.rotate(rBody.a);
        rBody.t += rp.cross(tf);
    }

    public inline function limitVelocity() {
        var vx = rBody.x;
        var vy = rBody.y;
        var omega = rBody.w;
        rBody.x = Vector.clamp(vx, -maxLinVel, maxLinVel);
        rBody.y = Vector.clamp(vy, -maxLinVel, maxLinVel);
        rBody.w = Vector.clamp(omega, -maxAngVel, maxAngVel);
    }

    public inline function updateState() {
        state.linVel = new Vector(rBody.x, rBody.y);
        state.speed = state.linVel.length();
        state.pos.x = rBody.x;
        state.pos.y = rBody.y;
        state.forward = engineForce.rotate(rBody.a);
    }

    public function explode() {
        /*
        for(bzShape shape = rBody.shapeList; shape; shape = shape.next) {
            auto bodyDef = new bzBodyDef;
            switch(shape.type) {
                case bzShapeType.POLYGON:
                    auto s = cast(bzPolygon) shape;
                    auto shapeDef = new bzPolyDef;
                    shapeDef.vertices = s.vertices;
                    shapeDef.density = s.density;
                    bodyDef.position = s.worldCenter;
                    bodyDef.a = randomRange(-PI, PI);
                    bodyDef.allowFreeze = false;
                    bodyDef.allowSleep = false;
                    auto shrapnel = world.createBody(bodyDef);
                    shrapnel.createShape(shapeDef);
                    bzMassData massData;
                    massData.mass = 5.0f;
                    shrapnel.setMass(massData);
                    float x = randomRange(-300, 300);
                    float y = randomRange(-300, 300);
                    shrapnel.linearVelocity = bzVec2(x, y);
                    break;
                default:
                    break;
            }
        }
        */
    }

    function setPlanetGravity() {
        var minRadius = 0.1;
        var maxRadius = 10.0;
        var strength = 1.75;
        var center = Vector.init();
        //auto attractor = new bzAttractor(rBody, center, strength, minRadius, maxRadius);
        //world.addForce(attractor);
    }
}
