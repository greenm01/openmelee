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
module System;

import tango.math.Math;
import tango.core.Array;
import tango.util.collection.ArraySeq;

import Vector2D;
import ChainHull;
import Mpr;

const SCALE = 5;            // Poltgon scale factor
const CIRCLE_SEGS = 50;

class RigidSys
{
    RigidBody[] rb;
    Vector[] mink, minkHull;

    Vector range;
    Vector cp1,cp2;

    int shape1 = 1;			            // Polygon #1 shape
    int shape2 = 5;			// Polygon #2 shape
    int scale = SCALE;

    double[][] minkSum;
    bool penetrate;

    Vector[] sA;            // Rigid Body 1 support map
    Vector[] sB;            // Rigid Body 2 support map
    Vector[] sAB;           // CSO

    Vector point1;
    Vector point2;
    Vector returnNormal;
    Vector v0,v1,v2,v3;

    this(long MAXRB)
    {
        rb.length = MAXRB;
        rb[0] = new RigidBody(shape1);
        rb[1] = new RigidBody(shape2);

        rb[0].pos = Vector(40.0f, 20.0f);
        rb[0].vel = Vector(0.0f,0.0f);
        rb[0].omega = 0.01;

        rb[1].pos = Vector(40.0f, 40.0f);
        rb[1].vel = Vector(0.1f,0.0f);
        rb[1].omega = 0.01;
    }

    void update()								                                // Update world
    {

        float dt = 1.0f/60.0f;

        rb[0].update(dt);
        rb[1].update(dt);

        // Clear display infromation
        sA = null;
        sB = null;
        sAB = null;
        point1 = Vector(0f,0f);
        point2 = Vector(0f,0f);

        penetrate = collideAndFindPoint(rb[0], rb[1], returnNormal, point1, point2, sAB, sA, sB);

        minkDiff();

    }

    void spawn(int hull)							                            // Change Polygon Shape
    {
        if (hull == 1) rb[0].shape(shape1);
        else rb[1].shape(shape2);
    }

    private void minkDiff()								                    // Calculate Minkowski Difference for display
    {
        int scale = rb[1].vertex.length*rb[0].vertex.length;
        minkSum = new double[][](scale,2);
        mink.length = minkHull.length = scale;

        int i = 0;
        foreach(rb1; rb[1].vertex)
            foreach(rb2; rb[0].vertex)
            {
                minkSum[i][0] = rb1.x - rb2.x;
                minkSum[i++][1] = rb1.y - rb2.y;
            }

        sort(minkSum);

        i = 0;
        foreach(inout m; mink)
        {
            m.x = minkSum[i][0];
            m.y = minkSum[i++][1];
        }

        foreach(inout v; minkHull)
        {
            v.x = 0;    // Clear Vector
            v.y = 0;
        }

        chainHull_2D(mink,minkHull);					            // Find Minkowski Hull
    }

}
private class RigidBody
{

    Vector[] V;
    Vector[] vertex;

    // State variables
    Vector pos;					// Position of center of mass
    float q;					// Rotation position

    // Derived quantities (auxiliary variables)
    Vector vel;					// linear velocity
    float omega;				// angular velocity

    int type;

    float radius;

    this(int s)
    {
        type = s;
        shape(type);
        q = 0.0001f;
        transform();

    }

    void shape(int hull)
    {
        type = hull;
        switch (hull)
        {
        case 1:		// Triangle
        {
            V = null;
            vertex = null;
            V ~= Vector(0,1);
            V ~= Vector(1,-1);
            V ~= Vector(-1,-1);
            vertex.length = V.length;
            break;
        }
        case 2:		// Quad
        {
            V = null;
            vertex = null;
            V ~= Vector(1,1);
            V ~= Vector(1,-1);
            V ~= Vector(-1,-1);
            V ~= Vector(-1,1);
            vertex.length = V.length;
            break;

        }
        case 3:		// Pentagon
        {
            V = null;
            vertex = null;
            V ~= Vector(1,1);
            V ~= Vector(2,0);
            V ~= Vector(0,-2);
            V ~= Vector(-2,0);
            V ~= Vector(-1,1);
            vertex.length = V.length;
            break;
        }
        case 4:		// Hexagon
        {
            V = null;
            vertex = null;
            V ~= Vector(1,1);
            V ~= Vector(1.5,0);
            V ~= Vector(0.5,-3);
            V ~= Vector(-0.5,-3);
            V ~= Vector(-1.5,0);
            V ~= Vector(-1,1);
            vertex.length = V.length;
            break;
        }
        case 5:		// Circle
        {
            radius = 1.5;
            V = null;
            vertex = null;

            int segs = CIRCLE_SEGS;
            Vector c = pos;
            float r = radius;
            float coef = 2.0*PI/segs;

            for(int n = 0; n <= segs; n++)
            {
                float rads = n*coef;
                V ~= Vector(r*cos(rads), r*sin(rads));
            }
            vertex.length = V.length;

            break;
        }
        }
    }

    void update(float dt)
    {
        pos.x += vel.x*dt;
        pos.y += vel.y*dt;
        q += omega*dt;

        transform();
    }

    void transform()
    {
        // Update world coordinates
        float degrees = q * 180f/PI;			// convert Polar rotation to cartesian coordinates

        while (degrees > 360f) degrees -= 360f;
        while (degrees < -360f) degrees += 360f;

        float cd = cos(degrees);
        float sd = sin(degrees);

        foreach(int i, v; V)
        {
            vertex[i].x = pos.x + SCALE*(v.x*cd + v.y*sd);
            vertex[i].y = pos.y + SCALE*(-v.x*sd + v.y*cd);
        }
    }

    Vector support(Vector n)
    {
        Vector r;

        if(type == 5)
        {
            r = radius * n.getNormal * SCALE;
            r = r + pos;
        }
        else
        {
            int i = vertex.length-1;
            r = vertex[i--];
            while (i>=0)
            {
                if ( (vertex[i] - r) * n >= 0 )
                {
                    r = vertex[i];
                }
                i--;
            }
        }
        return r;
    }

    Vector getCenter()
    {
        return pos;
    }
}

