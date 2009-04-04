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
package utils;

// Vector utility functions
class Util
{
    public static inline function rotate(v:Vec2, angle:Float) {
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        return new Vec2((cos * v.x) - (sin * v.y), (cos * v.y) + (sin * v.x));
    }
    
    public static inline function cross(a:Vec2, b:Vec2) {
        return a.x * b.y - a.y * b.x;
    }
    
    public static inline function dot(a:Vec2, b:Vec2) {
        return a.x * b.x + a.y * b.y;
    }
    
    public static inline function clamp (a:Float, low:Float, high:Float) {
        return Math.max(low, Math.min(a, high));
    }
    
    public static inline function mul22(A:Mat22, v:Vec2) {
       return new Vec2(dot(v, A.col1), dot(v, A.col2));
    }

    public static inline function mulXF(T:XForm, v:Vec2) {
        return mul22(T.R, v.sub(T.position));
    }
}
