/* MPR2D - A 2D implementation of the Minkowski Portal Refinement algorithm.
 * Copyright (C) 2008 Mason A. Green (Zzzzrrr)
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 *    1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 *
 *    2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 *
 *    3. This notice may not be removed or altered from any source
 *    distribution.
 *
 */
module Vector2D;

import tango.math.Math;
import tango.util.collection.ArraySeq;

const EPSILON = float.epsilon;

struct Vector
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
