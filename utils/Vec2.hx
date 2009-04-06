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

class Vec2
{
    public static var EPSILON = 1e-5;
    
    public var x : Float;
    public var y : Float;
    
    public function new(x:Float, y:Float) {
       this.x = x;
       this.y = y;
    }
    
    public inline function clone() {
        return new Vec2(x, y);
    }
    
    public inline function zero() {
        x = 0.0;
        y = 0.0;
    }
    
    public inline function isZero() {
        return(x == 0 && y == 0);
    }
    
    public inline function set(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }
    
    public inline function normalize() {
        var m = length();
        x *= 1.0/m;
        y *= 1.0/m;
    }

    public inline function getNormal() {
        var m = length();
        return new Vec2(x/m,y/m);
    }

    public inline function add(u:Vec2) {
        return new Vec2(x + u.x, y + u.y);
    }

    public inline function addAsn(u:Vec2) {
        x += u.x;
        y += u.y;
    }

    public inline function subAsn(u:Vec2) {
        x -= u.x;
        y -= u.y;
    }

    public inline function sub(u:Vec2) {
        return new Vec2(x - u.x, y - u.y);
    }

    public inline function mul(s:Float)	{
        return new Vec2(x*s, y*s);
    }
    
    public inline function mulAsn(s:Float) {
        x *= s;
        y *= s;
    }

    public inline function rotateLeft90() {
        return new Vec2( -y, x );
    }

    public inline function rotateRight90() {
        return new Vec2( y, -x );
    }

    public inline function length() {
        return Math.sqrt(x*x + y*y);
    }

    public inline function neg() {
        return new Vec2(-x, -y);
    }
    
    public inline function rotate(angle:Float) {
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        return new Vec2((cos * x) - (sin * y), (cos * y) + (sin * x));
    }
    
    public inline function cross(v:Vec2) {
        return x * v.y - y * v.x;
    }
    
    public inline function dot(v:Vec2) {
        return x * v.x + y * v.y;
    }
    
    public static inline function clamp (a:Float, low:Float, high:Float) {
        return Math.max(low, Math.min(a, high));
    }
    
    public static function mul22(A:Mat22, v:Vec2) {
       return new Vec2(v.dot(A.col1), v.dot(A.col2));
    }

    public static function mulXF(T:XForm, v:Vec2) {
        return mul22(T.R, v.sub(T.position));
    }
}
