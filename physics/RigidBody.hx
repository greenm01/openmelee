/*
 * Copyright (c) 2009, Mason Green 
 * http://github.com/zzzzrrr/haxmel
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
package physics;
 
import haxe.FastList;

import utils.Vec2;
import utils.Util;

enum DebugShape {
    TRIANGLE;
    QUAD;
    PENTAGON;
    HEXAGON;
    CIRCLE;
}

// For mpr algorithm testing
class RigidBody
{
    // Poltgon scale factor
    public static var SCALE = 5; 
    
    var vL : FastList<Vec2>;
    public var vW : FastList<Vec2>;
    
    // State variables
    // Global position of center of mass
    public var pos : Vec2;	
    // Local position of center of mass
    public var center : Vec2;
    // Rotation position				
    public var q : Float;					

    // Derived quantities (auxiliary variables)
    // linear velocity
    public var vel : Vec2;					
    // angular velocity
    public var omega : Float;				

    public var type : DebugShape;
    public var radius : Float;

    public function new(type:DebugShape) {
        pos = new Vec2(0,0);
        center = new Vec2(0,0);
        vel = new Vec2(0,0);
        this.type = type;
        shape(type);
        q = 0.0001;
        transform();
    }

    public function shape(hull:DebugShape) {
        type = hull;
        vL = new FastList();
        switch (hull)
        {
        case DebugShape.TRIANGLE:		
            vL.add(new Vec2(0,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
        case DebugShape.QUAD:		
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
            vL.add(new Vec2(-1,1));
        case DebugShape.PENTAGON:		
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(2,0));
            vL.add(new Vec2(0,-2));
            vL.add(new Vec2(-2,0));
            vL.add(new Vec2(-1,1));
        case DebugShape.HEXAGON:		
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1.5,0));
            vL.add(new Vec2(0.5,-3));
            vL.add(new Vec2(-0.5,-3));
            vL.add(new Vec2(-1.5,0));
            vL.add(new Vec2(-1,1));
        case DebugShape.CIRCLE:		
            radius = 1.5;
            var segs = 10;
            var c = pos;
            var r = radius;
            var coef = 2.0*Math.PI/segs;
            for(n in 0...segs+1) {
                var rads = n*coef;
                vL.add(new Vec2(r*Math.cos(rads), r*Math.sin(rads)));
            }
        }
    }

    public function update(dt:Float) {
        pos.x += vel.x*dt;
        pos.y += vel.y*dt;
        q += omega*dt;
        transform();
    }

    // Updat world coordinates
    private function transform() {
        var degrees = q * 180.0/Math.PI;			
        while (degrees > 360) degrees -= 360;
        while (degrees < -360) degrees += 360;
        var cd = Math.cos(degrees);
        var sd = Math.sin(degrees);
        vW = new FastList();
        for(v in vL) {
            var x = pos.x + (v.x*cd + v.y*sd);
            var y = pos.y + (-v.x*sd + v.y*cd);
            vW.add(new Vec2(x,y));
        }
    }

    public function support(n:Vec2) {
        var r = new Vec2(0,0);
        if(type == DebugShape.CIRCLE) {
            r = n.getNormal().mul(radius);
            r.addAsn(pos);
        } else {
            r = vW.first();
            for(v in vW) {
                if (Util.dot(v.sub(r), n) >= 0 ) {
                    r = v;
                }
            }
        }
        return r;
    }
}
