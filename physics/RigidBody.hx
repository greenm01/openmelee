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

enum ShapeType {
    TRIANGLE;
    QUAD;
    PENTAGON;
    HEXAGON;
    CIRCLE;
}

// For mpr algorithm testing
class RigidBody
{
    var vL : FastList<Vec2>;
    var vW : FastList<Vec2>;
    
    // State variables
    // Global position of center of mass
    public var pos : Vec2;	
    // Local position of center of mass
    public var center : Vec2;
    // Rotation position				
    var q : Float;					

    // Derived quantities (auxiliary variables)
    // linear velocity
    var vel : Vec2;					
    // angular velocity
    var omega : Float;				

    var type : ShapeType;
    var radius : Float;

    public function new(type:ShapeType) {
        pos = new Vec2(0,0);
        center = new Vec2(0,0);
        vel = new Vel(0,0);
        this.type = type;
        shape(type);
        q = 0.0001;
        transform();
    }

    private function shape(hull:ShapeType) {
        type = hull;
        switch (hull)
        {
        case ShapeType.TRIANGLE:		
            vL = new FastList();
            vL.add(new Vec2(0,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
        case ShapeType.QUAD:		
            vL = new FastList();
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
            vL.add(new Vec2(-1,1));
        case ShapeType.PENTAGON:		
            vL = new FastList();
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(2,0));
            vL.add(new Vec2(0,-2));
            vL.add(new Vec2(-2,0));
            vL.add(new Vec2(-1,1));
        case ShapeType.HEXAGON:		
            vL = new FastList();
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1.5,0));
            vL.add(new Vec2(0.5,-3));
            vL.add(new Vec2(-0.5,-3));
            vL.add(new Vec2(-1.5,0));
            vL.add(new Vec2(-1,1));
        case ShapeType.CIRCLE:		
            radius = 1.5;
            vL = null;
        }
    }

    public function update(dt:Float) {
        pos.x += vel.x*dt;
        pos.y += vel.y*dt;
        q += omega*dt;
        transform();
    }

    private function transform() {
        // Update world coordinates
        //Polar rotation to cartesian coordinates
        var degrees = q * 180.0/Math.PI;			

        while (degrees > 360) degrees -= 360;
        while (degrees < -360) degrees += 360;

        var cd = Math.cos(degrees);
        var sd = Math.sin(degrees);

        vW = new FastList();
        for(v in vL) {
            var x = pos.x + SCALE*(v.x*cd + v.y*sd);
            var y = pos.y + SCALE*(-v.x*sd + v.y*cd);
            vW.add(new Vec2(x,y));
        }
    }

    private function support(n:Vec2) {
        var r = new Vec2(0,0);
        if(type == ShapeType.CIRCLE) {
            r = n.getNormal.mul(radius).mul(SCALE);
            r = r.add(pos);
        } else {
            var i = vW.length-1;
            r = vW[i--];
            while (i>=0)
            {
                if ( (vW[i] - r) * n >= 0 )
                {
                    r = vW[i];
                }
                i--;
            }
        }
        return r;
    }
}
