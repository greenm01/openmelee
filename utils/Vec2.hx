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

import tango.math.Math;
import tango.util.collection.ArraySeq;

const EPSILON = float.epsilon;

class Vec2
{
    double x = 0f, y = 0f;

    static Vector opCall(double ax, double ay)
    {
        Vector u;
        u.x = ax;
        u.y = ay;
        return u;
    }

    void normalize()
    {
        double m = magnitude();
        x *= 1.0f/m;
        y *= 1.0f/m;
    }

    Vector getNormal()
    {
        double m = magnitude();
        return Vector(x/m,y/m);
    }


    Vector opAdd(Vector u)
    {
        return Vector(x + u.x, y + u.y);
    }

    void opAddAssign(Vector u)
    {
        x += u.x;
        y += u.y;
    }

    void opSubAssign(Vector u)
    {
        x -= u.x;
        y -= u.y;
    }

    Vector opSub(Vector u)
    {
        return Vector(x - u.x, y - u.y);
    }

    real opMul(Vector u)			// Vector Dot Product
    {
        return(x*u.x + y*u.y);
    }

    Vector opMul(double s)			// Scaler Multiplication
    {
        return Vector(x*s, y*s);
    }

    // Perp-dot product
    float opXor(Vector v)
    {
        return x * v.y - y * v.x;
    }

    // Perp-dot product
    float cross(Vector v)
    {
        return x * v.y - y * v.x;
    }

    Vector rotateLeft90()
    {
        return Vector( -y, x );
    }

    Vector rotateRight90()
    {
        return Vector( y, -x );
    }

    real magnitude()
    {
        if(x == 0.0f) x = EPSILON;
        if(y == 0.0f) y = EPSILON;
        return sqrt(x*x + y*y);
    }

    bool isZero()
    {
        return ( x < EPSILON && x > -EPSILON && y < EPSILON && y > -EPSILON);
    }

    // negation
    Vector opNeg()
    {
        return Vector(-x, -y);
    }

    Vector rotate(Vector v)
    {
        return Vector(x * v.x - y * v.y, x * v.y + y * v.x);
    }
}
