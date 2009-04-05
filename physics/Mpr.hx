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

class Mpr
{
    
    static var SIMPLEX_EPSILON = 1e-2;
    static var EPSILON = 1e-5;
    
    public function new() {
    }

    function insidePortal(v1:Vec2, v2:Vec2) {
        // Perp-dot product
        var dir = v1.x * v2.y - v1.y * v2.x;
        var v = new Vec2(v1.x-v2.x, v1.y-v2.y);
        if (dir > EPSILON) {
            return v.rotateLeft90();
        }
        return v.rotateRight90();
    }

    function outsidePortal(v1:Vec2, v2:Vec2) {
        // Perp-dot product
        var dir = v1.x * v2.y - v1.y * v2.x;
        var v = new Vec2(v1.x-v2.x, v1.y-v2.y);
        if (dir < EPSILON) {
            return v.rotateLeft90();
        }
        return v.rotateRight90();
    }

    function originInTriangle(a:Vec2, b:Vec2, c:Vec2) {
        
        var ab = b.sub(a);
        var bc = c.sub(b);
        var ca = a.sub(c);

        var pab =  Util.cross(a.neg(),ab);
        var pbc =  Util.cross(b.neg(),bc);
        var sameSign = (pab < 0) == (pbc < 0);
        if (!sameSign) return false;

        var pca = Util.cross(c.neg(), ca);
        sameSign = (pab < 0) == (pca < 0);
        if (!sameSign) return false;
        return true;
    }

    function intersectPortal(v0:Vec2, v1:Vec2, v2:Vec2) {
        var a = new Vec2(0,0);
        var b = v0.clone();
        var c = v1.clone();
        var d = v2.clone();
        var a1 = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);
        var a2 = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
        if (a1 != 0.0 && a2 != 0.0 && a1*a2 < 0.0){
            var a3 = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
            var a4 = a3 + a2 - a1;
            if (a3 != 0.0 && a4 != 0.0 && a3*a4 < 0.0) return true;
        }
        // Segments not intersecting (or collinear)
        return false;
    }

   public function collide(shape1:RigidBody, shape2:RigidBody, returnNormal:Vec2, point1:Vec2, 
                           point2:Vec2, sAB:Array<Vec2>, sA:Array<Vec2>, sB:Array<Vec2>) {

        // Phase one: Portal discovery
        
        // v0 = center of Minkowski sum
        var v01 = shape1.pos;
        var v02 = shape2.pos;
        var v0 = v02.sub(v01);

        // Avoid case where centers overlap -- any direction is fine in this case
        if (v0.isZero()) v0 = new Vec2(0.00001, 0);

        // v1 = support in direction of origin
        var n  = v0.neg();
        var v11 = shape1.support(n.neg());
        var v12 = shape2.support(n);
        var v1 = v12.sub(v11);

        sA[sA.length] = v11;
        sB[sB.length] = v12;

        // origin outside v1 support plane ==> miss
        if (Util.dot(v1, n) <= 0) return false;

        // Find a candidate portal
        n = outsidePortal(v1, v0);
        var v21 = shape1.support(n.neg());
        var v22 = shape2.support(n);
        var v2 = v22.sub(v21);

        if(sA[sA.length-1] != v21) sA[sA.length] = v21;
        if(sB[sB.length-1] != v22) sB[sB.length] = v22;

        // origin outside v2 support plane ==> miss
        if (Util.dot(v2, n) <= 0) return false;

        // Phase two: Portal refinement
        var maxIterations = 0;
        while (true) {
            // Find normal direction
            if(!intersectPortal(v0, v2, v1)) {
                n = insidePortal(v2,v1);
            } else {
                // Origin ray crosses the portal
                n = outsidePortal(v2, v1);
            }
            // Obtain the next support point
            var v31 = shape1.support(n.neg());
            var v32 = shape2.support(n);
            var v3 = v32.sub(v31);
            if(sA[sA.length-1] != v21) sA[sA.length] = v31;
            if(sB[sB.length-1] != v22) sB[sB.length] = v32;
            if (Util.dot(v3,n) <= 0) {
                var ab = v3.sub(v2);
                var t = -Util.dot(v2,ab)/Util.dot(ab,ab);
                var tmp = v2.add(ab.mul(t));
                returnNormal.set(tmp.x, tmp.y);
                return false;
            }
            // Portal lies on the outside edge of the Minkowski Hull.
            // Return contact information
            if(Util.dot(v3.sub(v2),n) <= SIMPLEX_EPSILON || ++maxIterations > 3) {
                var ab = v2.sub(v1);
                var t = Util.dot(v1.neg(),ab);
                if (t <= 0.0) {
                    t   = 0.0;
                    returnNormal.set(v1.x, v1.y);
                } else {
                    var denom = Util.dot(ab,ab);
                    if (t >= denom) {
                        returnNormal.set(v2.x, v2.y);
                        t   = 1.0;
                    } else {
                        t  /= denom;
                        var t1 = v1.add(ab.mul(t));
                        returnNormal.set(t1.x, t1.y);
                    }
                }
                var s = 1 - t;
                var t1 = v11.mul(s).add(v21.mul(t));
                var t2 = v12.mul(s).add(v22.mul(t));
                point1.set(t1.x, t1.y);
                point2.set(t2.x, t2.y);
                sAB[sAB.length] = v0;
                sAB[sAB.length] = v1;
                sAB[sAB.length] = v2;
                return true;
            }
            // If origin is inside (v1,v0,v3), refine portal
            if (originInTriangle(v0, v1, v3)) {
                v2 = v3;
                v21 = v31;
                v22 = v32;
                continue;
            } else if (originInTriangle(v0, v2, v3)) {
                // If origin is inside (v3,v0,v2), refine portal
                v1 = v3;
                v11 = v31;
                v12 = v32;
                continue;
            }
            return false;
        }
        // This should never happpen.....
        throw "mpr error";
    }
}
