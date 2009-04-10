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
package utils;

import phx.Vector;

class Util
{

    public static function scalarRandomWalk(initial:Float, walkspeed:Float, min:Float, max:Float) {
        
        var next = initial + (((randomRange(0, 1) * 2) - 1) * walkspeed);
        if (next < min) return min;
        if (next > max) return max;
        return next;
    }

    // return component of vector perpendicular to a unit basis vector
    // IMPORTANT NOTE: assumes "basis" has unit magnitude(length==1)
    public static function perpendicularComponent(v:Vector, unitBasis:Vector) {
        return v.minus(parallelComponent(v, unitBasis));
    }

    // return component of vector parallel to a unit basis vector
    // IMPORTANT NOTE: assumes "basis" has unit magnitude (length == 1)
    public static function parallelComponent(v:Vector, unitBasis:Vector) {
        var projection = v.dot(unitBasis);
        return unitBasis.mult(projection);
    }
            
    // ----------------------------------------------------------------------------
    // classify a value relative to the interval between two bounds:
    //     returns -1 when below the lower bound
    //     returns  0 when between the bounds (inside the interval)
    //     returns +1 when above the upper bound
    public static function intervalComparison(x:Float, lowerBound:Float, upperBound:Float) {
        if (x < lowerBound) return -1;
        if (x > upperBound) return 1;
        return 0;
    }
            
    public static inline function randomRange(min:Float, max:Float) {
	    var rand = Math.random() * 1e99;
	    return min + rand % (max + 1 - min);
    }
}
