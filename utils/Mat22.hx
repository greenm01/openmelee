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

///
class Mat22
{
    /**
     * The columns
     */
    public var col1 : Vec2;
    public var col2 : Vec2;

    public function new(c1:Vec2, c2:Vec2) {
        this.col1 = c1;
        this.col2 = c2;
    }

    static public function init() {
        var c1 = Vec2.init();
        var c2 = Vec2.init();
        return new Mat22(c1, c2);
    }

    public inline function set(angle:Float) {
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        col1.x = c;
        col2.x = -s;
        col1.y = s;
        col2.y = c;
    }

    public inline function setCols(c1:Vec2, c2:Vec2) {
        col1 = c1;
        col2 = c2;
    }

    public inline function setIdentity() {
        col1.x = 1.0;
        col2.x = 0.0;
        col1.y = 0.0;
        col2.y = 1.0;
    }

    public inline function zero() {
        col1.x = 0.0;
        col2.x = 0.0;
        col1.y = 0.0;
        col2.y = 0.0;
    }

    public inline function invert() {
        var a = col1.x;
        var b = col2.x;
        var c = col1.y;
        var d = col2.y;
        var det = a * d - b * c;
        if(det == 0.0) throw "invert error";
        det = 1.0 / det;
        col1.x =  det * d;
        col2.x = -det * b;
        col1.y = -det * c;
        col2.y =  det * a;
    }

    /**
     * Compute the inverse of this matrix
     */
    public inline function inverse() {
        var a = col1.x;
        var b = col2.x;
        var c = col1.y;
        var d = col2.y;
        var det = a * d - b * c;
        if(det == 0.0) throw "invert error";
        det = 1.0 / det;
        var col1 = new Vec2(0,0);
        var col2 = new Vec2(0,0);
        col1.x =  det * d;
        col2.x = -det * b;
        col1.y = -det * c;
        col2.y =  det * a;
        return new Mat22(col1, col2);
    }

    /**
     * Solve A * x = b, where b is a column vector. This is more efficient
     * than computing the inverse in one-shot cases.
     * Params: b = the column vector
     * Returns: x
     */
    public inline function solve(b:Vec2) {
        var a11 = col1.x;
        var a12 = col2.x;
        var a21 = col1.y;
        var a22 = col2.y;
        var det = a11 * a22 - a12 * a21;
        if(det == 0.0) throw "invert error";
        det = 1.0 / det;
        var x = new Vec2(0,0);
        x.x = det * (a22 * b.x - a12 * b.y);
        x.y = det * (a11 * b.y - a21 * b.x);
        return x;
    }

    /**
     * Adds each element of the matrix to each corresponding element of the
     * other matrix
     * Params: B = the other matrix
     * Returns: A new matrix containing the result of the addition
     */
    public inline function add(B:Mat22) {
        var c1 = col1.add(B.col1);
        var c2 = col2.add(B.col2);
        return new Mat22(c1, c2);
    }
}
