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
import phx.Polygon;

import ships.GameObject;
import utils.Util;
import melee.Melee;

class Ship extends GameObject
{
    var shapeList : FastList<Shape>;
    var engineForce : Vector;
    var turnForce : Vector;
    var leftTurnPoint : Vector;
    var rightTurnPoint : Vector;
    var battery : Float;
    var maxLinVel : Float;
    var maxAngVel : Float;

    public function new(melee:Melee) {
        super(melee);
        shapeList = new FastList<Shape>();
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

    public override function limitVelocity() {
        var vx = rBody.x;
        var vy = rBody.y;
        var omega = rBody.w;
        rBody.x = Util.clamp(vx, -maxLinVel, maxLinVel);
        rBody.y = Util.clamp(vy, -maxLinVel, maxLinVel);
        rBody.w = Util.clamp(omega, -maxAngVel, maxAngVel);
    }

    public override function updateState() {
        state.linVel.set(rBody.x, rBody.y);
        state.speed = state.linVel.length();
        state.pos.x = rBody.x;
        state.pos.y = rBody.y;
        state.forward = engineForce.rotate(rBody.a);
    }

    public override function destroy() {
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
        world.removeBody(rBody);
        return true;
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
    
    public function fire() {}
}
