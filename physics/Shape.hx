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

/**
 * This holds the mass data computed for a shape.
 */
typedef MassData = {
    /**
	 * The mass of the shape, usually in kilograms.
	 */
    var mass : Float;

    /**
     * The position of the shape's centroid relative to the shape's origin.
	 */
    var center : Vec2;

    /**
     * The rotational inertia of the shape.
     */
    var I : Float;
}

class Shape
{

    public static inline var CIRCLE = 0;
	public static inline var SEGMENT = 1;
	public static inline var POLYGON = 2;
    
    public var body : Body;
    public var radius : Float;
    public var massData : MassData;
    public var density : Float;
    // Local position in parent body
    public var offset : Vec2;
    public var type : Int;
    // Axis aligned bounding box
    var aabb : AABB;
    
    public function new(type:Int, offset:Vec2, density:Float) {
        this.type = type;
        this.offset = offset;
        this.density = density;
        aabb = new AABB(new Vec2(0.0,0.0), new Vec2(0.0,0.0));
        //massData = {mass:0.0, center:new Vec2(0,0), I:0.0};
    }

    public inline function support(d:Vec2);
    public function computeMass();
    public inline function synchronize();

}
