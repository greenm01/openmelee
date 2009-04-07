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

import utils.Vec2;

class Circle extends Shape
{
    
    var worldCenter : Vec2;
    
    public function new(offset:Vec2, radius:Float, density:Float) {
        super(Shape.CIRCLE, offset, density);
        worldCenter = new Vec2(0.0,0.0);
        super.radius = radius;
        computeMass();
    }
    
    // Synchronize world center
    public override inline function synchronize() {
        worldCenter = Vec2.mulXF(body.xf, offset);
    }
    
    /**
	 * Compute the mass properties of this shape using its dimensions and density.
     * The inertia tensor is computed about the local origin, not the centroid.
     * Params: massData = returns the mass data for this shape.
	 */
    public function computeMass() {
        massData.mass = density * Math.PI * radius * radius;
        massData.center = offset;
        // inertia about the local origin
        massData.I = massData.mass * (0.5 * radius * radius + offset.dot(offset));
    }
    
    /**
     * Returns: The shape's support point (for MPR)
     */
    public inline override function support(d:Vec2) {
        d.normalize();
        var r = d.mul(radius);
        r += worldCenter;
        return r;
    }
}
