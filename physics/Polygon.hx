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

class Polygon extends Shape
{

    // Vertices in local coordinates
    var vertices : Array<Vec2>;
    // Vertices in world coordinates
    public var worldVerts : FastList<Vec2>;
    var area : Float;

    public function new(vertices:Array<Vec2>, offset:Vec2, density:Float) {

        super(Shape.POLYGON, offset, density);
        polygon = this;

        this.vertices = vertices;
        worldVerts = new FastList();
        for(v in 0...vertices.length) {
            worldVerts.add(new Vec2(0.0,0.0));
        }

        updateRadius();
    }

    function updateRadius() {
        radius = 0.0;
        for (v in vertices) {
            radius = Math.max(radius, v.length());
        }
    }

    public function updateAABB() {
        aabb.upperBound.x = worldCenter.x + radius;
        aabb.upperBound.y = worldCenter.y + radius;
        aabb.lowerBound.x = worldCenter.x - radius;
        aabb.lowerBound.y = worldCenter.y - radius;
    }

    // Synchronize world vertices in local space
    public override function synchronize() {
        worldCenter = body.pos.add(offset);
        var i = 0;
        for(v in worldVerts) {
            var p = Vec2.mul22(body.xf.R, vertices[i++]);
            v.set(p.x+worldCenter.x, p.y+worldCenter.y);
        }
    }

    /**
	 * Returns: The shape's support point (for MPR & GJK)
	 */
    public override function support(d:Vec2) : Vec2 {
        var dLocal = Vec2.mul22(body.xf.R, d);
        var bestIndex = 0;
        var bestValue = vertices[0].dot(dLocal);
        for (i in 1...vertices.length) {
            var value = vertices[i].dot(dLocal);
            if (value > bestValue) {
                bestIndex = i;
                bestValue = value;
            }
        }
        return Vec2.mulXF(body.xf, vertices[bestIndex]);
    }

    /**
	 * Compute the mass properties of this shape using its dimensions and density.
     * The inertia tensor is computed about the local origin, not the centroid.
     * Params: massData = returns the mass data for this shape.
	 * Implements: blaze.collision.shapes.bzShape.bzShape.computeMass
	 */
    public override function computeMass() {

        // Polygon mass, centroid, and inertia.
        // Let rho be the polygon density in mass per unit area.
        // Then:
        // mass = rho * int(dA)
        // centroid.x = (1/mass) * rho * int(x * dA)
        // centroid.y = (1/mass) * rho * int(y * dA)
        // I = rho * int((x*x + y*y) * dA)
        //
        // We can compute these integrals by summing all the integrals
        // for each triangle of the polygon. To evaluate the integral
        // for a single triangle, we make a change of variables to
        // the (u,v) coordinates of the triangle:
        // x = x0 + e1x * u + e2x * v
        // y = y0 + e1y * u + e2y * v
        // where 0 <= u && 0 <= v && u + v <= 1.
        //
        // We integrate u from [0,1-v] and then v from [0,1].
        // We also need to use the Jacobian of the transformation:
        // D = bzCross(e1, e2)
        //
        // Simplification: triangle centroid = (1/3) * (p1 + p2 + p3)
        //
        // The rest of the derivation is handled by computer algebra.

        if(vertices.length < 3) throw "not a polygon";

        var center = Vec2.init();
		area = 0.0;
        var I = 0.0;

        // pRef is the reference point for forming triangles.
        // It's location doesn't change the result (except for rounding error).
        var pRef = Vec2.init();

        var k_inv3 = 1.0 / 3.0;

        for (i in 0...vertices.length) {
            // Triangle vertices.
            var p1 = pRef;
            var p2 = vertices[i];
            var p3 = if(i + 1 < vertices.length) vertices[i+1] else vertices[0];

            var e1 = p2.sub(p1);
            var e2 = p3.sub(p1);

            var D = e1.cross(e2);

            var triangleArea = 0.5 * D;
            area += triangleArea;

            // Area weighted centroid
            center.addAsn(p1.add(p2.add(p3)).mul(triangleArea * k_inv3));

            var px = p1.x;
            var py = p1.y;
            var ex1 = e1.x;
            var ey1 = e1.y;
            var ex2 = e2.x;
            var ey2 = e2.y;

            var intx2 = k_inv3 * (0.25 * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5*px*px;
            var inty2 = k_inv3 * (0.25 * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5*py*py;

            I += D * (intx2 + inty2);
        }

        // Total mass
        massData.mass = density * area;

        // Center of mass
        if(area < Vec2.EPSILON) throw "Bad polygon: area = " + area;
        center.mulAsn(1.0 / area);
        massData.center = center;

        // Inertia tensor relative to the local origin.
        massData.I = density * I;
    }

}
