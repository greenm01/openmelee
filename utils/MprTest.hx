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

import haxe.FastList;

import neko.Lib;

import opengl.GL;
import opengl.GLU;
import opengl.GLFW;

class MprTest {
    
	public static var i=0;
    static var system : System;
    static var close : Bool;
    
    static var closestFeatures : Bool = false;
    static var closestPoints : Bool = true;
    
    static function drawScene() {
        GLFW.swapInterval(1);
        GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
        drawBullsEye();
        drawMinkowskiHull();
        drawContactPoints();
        drawSimplex();
        GL.color3(1, 0, 0);
        for( b in system.rb) {
            drawShape(b);
            GL.color3(0, 1, 0);
        }
        GLFW.swapBuffers();
    }

	static function drawShape( b : RigidBody ) {
	    if(b.type == DebugShape.CIRCLE) {
	        drawCircle(b);
        } else {
            drawPoly(b);
        }
	}

	static function drawCircle( circle : RigidBody ) {
        var c = circle.pos;
        var r = circle.radius;
        var segs = 12;
        var coef = 2.0 * Math.PI / segs;
        var theta = circle.q;
        GL.begin(GL.LINE_STRIP); 
        {
            for (n in 0...segs+1) {
                var rads = n * coef;
                var x = r * Math.cos(rads + theta) + c.x;
                var y = r * Math.sin(rads + theta) + c.y;
                GL.vertex2(x, y);
            }
        } 
        GL.end();
        GL.loadIdentity();
        GL.flush();
	}

	static function drawPoly( polygon : RigidBody) {
        GL.begin( GL.LINE_LOOP );
        {
            for(v in polygon.vW) {
                GL.vertex2(v.x, v.y);
            }
        }
        GL.end();
        GL.loadIdentity();
        GL.flush();
    }
    
    static function drawContactPoints() {
        if (system.penetrate) {
            GL.loadIdentity();
            GL.color3(1,1,0);
            GL.begin(GL.POINTS);
            {
                GL.vertex2(system.returnNormal.x, system.returnNormal.y);
            }
            GL.end();
            GL.loadIdentity();
            GL.pointSize(10);
            GL.begin(GL.POINTS);
            {
                if(closestFeatures) {
                    GL.color3(1,0,0); 
                    for(v in system.sA) {
                        GL.vertex2(v.x, v.y);
                    }
                    GL.color3(0,1,0);  
                    for(v in system.sB) {
                        GL.vertex2(v.x, v.y);
                    }
                }

                if(closestPoints) {
                    GL.color3(1,0,0);  
                    GL.vertex2(system.point1.x, system.point1.y);
                    GL.color3(0,1,0);  
                    GL.vertex2(system.point2.x, system.point2.y);
                }
            }
            GL.end();
        } 
    }
    
    static function drawBullsEye() {
        GL.color3(0,0,1);	
        GL.lineWidth(2);
        GL.begin(GL.LINES);
        {
            GL.vertex2(0.0,1.0);
            GL.vertex2(0.0,-1.0);
            GL.vertex2(1.0,0.0);
            GL.vertex2(-1.0,0.0);
        }
        GL.end();
    }
    
    static function drawMinkowskiHull() {
        if(system.penetrate) {
            GL.color3(0,0,1);
        } else {
            GL.color3(1,1,1);
        }
        GL.begin(GL.LINE_STRIP);
        {
            for(m in system.minkHull) {
                if (m.x != 0.0 && m.y != 0.0) {
                    GL.vertex2(m.x, m.y);
                }
            }
        }
        GL.end();
    }
    
    static function drawSimplex() {
        GL.loadIdentity();
        GL.color3(1,1,0);
        GL.begin(GL.LINE_LOOP);
        {
            for(v in system.sAB) {
                GL.vertex2(v.x, v.y);
            }
        }
        GL.end();
    }
    
    static function initGL(left:Float, right:Float, bottom:Float, top:Float, viewCenter: Vec2) {
        GL.loadIdentity();
        GL.matrixMode(GL.PROJECTION);
        GLU.ortho2D(left, right, bottom, top);
        GL.translate(-viewCenter.x, -viewCenter.y, 0);
        GL.matrixMode(GL.MODELVIEW);
        GL.disable(GL.DEPTH_TEST);
        GL.shadeModel(GL.SMOOTH);
        GL.enable(GL.BLEND);
        GL.enable(GL.POINT_SMOOTH);
        GL.enable(GL.LINE_SMOOTH);
        GL.enable(GL.POLYGON_SMOOTH);
        GL.clearColor(0.0, 0.0, 0.0, 0.0);
        GL.hint(GL.PERSPECTIVE_CORRECTION_HINT, GL.NICEST);
        GL.loadIdentity();
 	}

	public static function main() {
	    
	    var hGrid = new physics.HGrid();
	    
        var screenSize = new Vec2(800, 600);
        var viewCenter : Vec2 = new Vec2(0,0);
        var zoom = 60;
		var close = false;
		
		var left = -screenSize.x / zoom;
        var right = screenSize.x / zoom;
        var bottom = -screenSize.y / zoom;
        var top = screenSize.y / zoom;

		GLFW.openWindow(Std.int(screenSize.x), Std.int(screenSize.y), 8,8,8, 8,8,0, GLFW.WINDOW );
		initGL(left, right, bottom, top, viewCenter);
		
		GLFW.setKeyFunction(onKey);
        GLFW.setWindowCloseFunction( function() {
			trace("window close" );
			close = true;
			return 1;
		});
		
        system = new System();
        var Hz = 90;

		while(!close) {
		    system.step(1/Hz);
		    drawScene();
			GLFW.pollEvents();
		} 
		GLFW.terminate();
		
		system.ms *= 1e3;
		trace("Collision ms/cycle: " + system.ms/system.index);
		
	}
	
	static var onKey = function(key:Int, state:Int) {
	     // Key pressed
		if (state == GLFW.PRESS) {
			switch (key) {
			    case GLFW.KEY_ESC:
			        close = true;
                case GLFW.KEY_RIGHT:
                    system.rb[1].vel.x += 5.0;
                case GLFW.KEY_LEFT:
                    system.rb[1].vel.x -= 5.0;
                case GLFW.KEY_UP:
                    system.rb[1].vel.y += 5.0;
                case GLFW.KEY_DOWN:
                    system.rb[1].vel.y -= 5.0;
                case GLFW.KEY_SPACE:
                    system.rb[1].vel.x = 0.0;
                    system.rb[1].vel.y = 0.0;
                    system.rb[1].omega = 0.0;
                case GLFW.KEY_RSHIFT:
                    system.rb[1].omega += 0.01;
                case GLFW.KEY_ENTER:
                    system.rb[1].omega -= 0.01;
                case 68:
                    trace("d");
                    system.rb[0].vel.x += 5.0;
                case 65:
                    trace("a");
                    system.rb[0].vel.x -= 5.0;
                case 87:
                    trace("w");
                    system.rb[0].vel.y += 5.0;
                case 83:
                    trace("s");
                    system.rb[0].vel.y -= 5.0;
                case 69:
                    trace("e");
                    system.rb[0].omega += 0.01;
                case 81:
                    trace("q");
                    system.rb[0].omega -= 0.01;
                case 67:
                    trace("c");
                    system.rb[0].vel.x = 0.0;
                    system.rb[0].vel.y = 0.0;
                    system.rb[0].omega = 0.0;
                case 80:
                    trace("p");
                    system.rb[0].q = 0.0;
                    system.rb[1].q = 0.0;
                case 93:
                    trace("]");
                    spawn(system.rb[0]);
                case 91:
                    trace("[");
                    spawn(system.rb[1]);
            }
        } else {
            // Key Released
        }
        return 1;
    }
    
    static function spawn(rb:RigidBody) {
        switch(rb.type) {
            case DebugShape.TRIANGLE:
                system.spawn(rb, DebugShape.QUAD);
            case DebugShape.QUAD:
                system.spawn(rb, DebugShape.PENTAGON);
            case DebugShape.PENTAGON:
                system.spawn(rb, DebugShape.HEXAGON);
            case DebugShape.HEXAGON:
                system.spawn(rb, DebugShape.CIRCLE);
            case DebugShape.CIRCLE:
                system.spawn(rb, DebugShape.TRIANGLE);
        }
    }
}

class System
{
    public static var CIRCLE_SEGS = 50;
    public var rb : Array<RigidBody>;

    public var range : Vec2;
    public var cp1 : Vec2;
    public var cp2 : Vec2;

    public var minkSum : Array<Vec2>;
    public var minkHull : Array<Vec2>;
    public var chainHull : ChainHull;
    
    public var penetrate : Bool;

    // CSO
    public var sA : Array<Vec2>;           
    public var sB : Array<Vec2>;                        
    public var sAB : Array<Vec2>;

    public var point1 : Vec2;
    public var point2 : Vec2;
    public var returnNormal : Vec2;
    
    var mpr : Mpr;
    
    public var ms : Float;
    public var index : Int;
    
    public function new() {
        
        ms = 0;
        index = 0;
        
        rb = new Array();
        sA = new Array();
        sB = new Array();
        sAB = new Array();
        mpr = new Mpr();
        chainHull = new ChainHull();
        returnNormal = new Vec2(0.0, 0.0);
        penetrate = false;
        
        rb[0] = new RigidBody(DebugShape.TRIANGLE);
        rb[0].pos = new Vec2(5.0, 5.0);
        rb[0].vel = new Vec2(0.0, 0.0);
        rb[0].omega = -0.01;

        rb[1] = new RigidBody(DebugShape.QUAD);
        rb[1].pos = new Vec2(5.0, -0.0);
        rb[1].vel = new Vec2(0.1, 0.0);
        rb[1].omega = 0.01;
        
        point1 = new Vec2(0,0);
        point2 = new Vec2(0,0);
    }

    public function step(dt:Float) {
        rb[0].update(dt);
        rb[1].update(dt);
        // Clear display infromation
        sA = new Array();
        sB = new Array();
        sAB = new Array();
        //point1.set(0,0);
        //point2.set(0,0);
        var t1 = neko.Sys.time();
        penetrate = mpr.collide(rb[0], rb[1], returnNormal, point1, point2, sAB, sA, sB);
        var t2 = neko.Sys.time();
        if(penetrate) {
            ms += (t2-t1);
            index++;
        } 
        minkDiff();

    }

    // Change Polygon Shape
    public function spawn(rb:RigidBody, hull:DebugShape) {
        rb.shape(hull);
    }

    // Calculate Minkowski Difference for display
    function minkDiff()	{							                    

        minkSum = new Array();
        var i = 0;
        for(rb1 in rb[1].vW) {
            for(rb2 in rb[0].vW) {
                minkSum[i++] = new Vec2(rb1.x - rb2.x, rb1.y - rb2.y);
            }
        }

        minkSum.sort(function(v1:Vec2, v2:Vec2) {
            if(v1.x == v2.x && v1.y == v2.y) return 0;
            if(v1.x < v2.x) return -1;
            return 1;
        });
        
        // Find Minkowski Hull
        minkHull = new Array();
        chainHull.compute(minkSum, minkHull);
    }
}

enum DebugShape {
    TRIANGLE;
    QUAD;
    PENTAGON;
    HEXAGON;
    CIRCLE;
}

// For mpr algorithm testing
class RigidBody
{
    // Poltgon scale factor
    public static var SCALE = 5; 
    
    var vL : FastList<Vec2>;
    public var vW : FastList<Vec2>;
    
    // State variables
    // Global position of center of mass
    public var pos : Vec2;	
    // Local position of center of mass
    public var center : Vec2;
    // Rotation position				
    public var q : Float;					

    // Derived quantities (auxiliary variables)
    // linear velocity
    public var vel : Vec2;					
    // angular velocity
    public var omega : Float;				

    public var type : DebugShape;
    public var radius : Float;

    public function new(type:DebugShape) {
        pos = new Vec2(0,0);
        center = new Vec2(0,0);
        vel = new Vec2(0,0);
        this.type = type;
        shape(type);
        q = 0.0001;
        transform();
    }

    public function shape(hull:DebugShape) {
        type = hull;
        vL = new FastList();
        switch (hull)
        {
        case DebugShape.TRIANGLE:		
            vL.add(new Vec2(0,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
        case DebugShape.QUAD:		
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
            vL.add(new Vec2(-1,1));
        case DebugShape.PENTAGON:		
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(2,0));
            vL.add(new Vec2(0,-2));
            vL.add(new Vec2(-2,0));
            vL.add(new Vec2(-1,1));
        case DebugShape.HEXAGON:		
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1.5,0));
            vL.add(new Vec2(0.5,-3));
            vL.add(new Vec2(-0.5,-3));
            vL.add(new Vec2(-1.5,0));
            vL.add(new Vec2(-1,1));
        case DebugShape.CIRCLE:		
            radius = 1.5;
            var segs = 10;
            var c = pos;
            var r = radius;
            var coef = 2.0*Math.PI/segs;
            for(n in 0...segs+1) {
                var rads = n*coef;
                vL.add(new Vec2(r*Math.cos(rads), r*Math.sin(rads)));
            }
        }
    }

    public function update(dt:Float) {
        pos.x += vel.x*dt;
        pos.y += vel.y*dt;
        q += omega*dt;
        transform();
    }

    // Updat world coordinates
    private function transform() {
        var degrees = q * 180.0/Math.PI;			
        while (degrees > 360) degrees -= 360;
        while (degrees < -360) degrees += 360;
        var cd = Math.cos(degrees);
        var sd = Math.sin(degrees);
        vW = new FastList();
        for(v in vL) {
            var x = pos.x + (v.x*cd + v.y*sd);
            var y = pos.y + (-v.x*sd + v.y*cd);
            vW.add(new Vec2(x,y));
        }
    }

    public function support(n:Vec2) {
        var r = new Vec2(0,0);
        if(type == DebugShape.CIRCLE) {
            r = n.getNormal().mul(radius);
            r.addAsn(pos);
        } else {
            r = vW.first();
            for(v in vW) {
                if (Vec2.dot(v.sub(r), n) >= 0 ) {
                    r = v;
                }
            }
        }
        return r;
    }
}

class Mpr
{
    
    static var SIMPLEX_EPSILON = 1e-2;
    static var EPSILON = 1e-5;
    
    public function new() {
    }

    function insidePortal(v1:Vec2, v2:Vec2) {
        // Perp-dot product
        var dir = v1.x * v2.y - v1.y * v2.x;
        var v = new Vec2(v1.x-v2.x, v1.y-v2.y);
        if (dir > EPSILON) {
            return v.rotateLeft90();
        }
        return v.rotateRight90();
    }

    function outsidePortal(v1:Vec2, v2:Vec2) {
        // Perp-dot product
        var dir = v1.x * v2.y - v1.y * v2.x;
        var v = new Vec2(v1.x-v2.x, v1.y-v2.y);
        if (dir < EPSILON) {
            return v.rotateLeft90();
        }
        return v.rotateRight90();
    }

    function originInTriangle(a:Vec2, b:Vec2, c:Vec2) {
        
        var ab = b.sub(a);
        var bc = c.sub(b);
        var ca = a.sub(c);

        var pab =  Vec2.cross(a.neg(),ab);
        var pbc =  Vec2.cross(b.neg(),bc);
        var sameSign = (pab < 0) == (pbc < 0);
        if (!sameSign) return false;

        var pca = Vec2.cross(c.neg(), ca);
        sameSign = (pab < 0) == (pca < 0);
        if (!sameSign) return false;
        return true;
    }

    function intersectPortal(v0:Vec2, v1:Vec2, v2:Vec2) {
        var a = new Vec2(0,0);
        var b = v0.clone();
        var c = v1.clone();
        var d = v2.clone();
        var a1 = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);
        var a2 = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
        if (a1 != 0.0 && a2 != 0.0 && a1*a2 < 0.0){
            var a3 = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
            var a4 = a3 + a2 - a1;
            if (a3 != 0.0 && a4 != 0.0 && a3*a4 < 0.0) return true;
        }
        // Segments not intersecting (or collinear)
        return false;
    }

   public function collide(shape1:RigidBody, shape2:RigidBody, returnNormal:Vec2, point1:Vec2, 
                           point2:Vec2, sAB:Array<Vec2>, sA:Array<Vec2>, sB:Array<Vec2>) {

        // Phase one: Portal discovery
        
        // v0 = center of Minkowski sum
        var v01 = shape1.pos;
        var v02 = shape2.pos;
        var v0 = v02.sub(v01);

        // Avoid case where centers overlap -- any direction is fine in this case
        if (v0.isZero()) v0 = new Vec2(0.00001, 0);

        // v1 = support in direction of origin
        var n  = v0.neg();
        var v11 = shape1.support(n.neg());
        var v12 = shape2.support(n);
        var v1 = v12.sub(v11);

        sA[sA.length] = v11;
        sB[sB.length] = v12;

        // origin outside v1 support plane ==> miss
        if (Vec2.dot(v1, n) <= 0) return false;

        // Find a candidate portal
        n = outsidePortal(v1, v0);
        var v21 = shape1.support(n.neg());
        var v22 = shape2.support(n);
        var v2 = v22.sub(v21);

        if(sA[sA.length-1] != v21) sA[sA.length] = v21;
        if(sB[sB.length-1] != v22) sB[sB.length] = v22;

        // origin outside v2 support plane ==> miss
        if (Vec2.dot(v2, n) <= 0) return false;

        // Phase two: Portal refinement
        var maxIterations = 0;
        while (true) {
            // Find normal direction
            if(!intersectPortal(v0, v2, v1)) {
                n = insidePortal(v2,v1);
            } else {
                // Origin ray crosses the portal
                n = outsidePortal(v2, v1);
            }
            // Obtain the next support point
            var v31 = shape1.support(n.neg());
            var v32 = shape2.support(n);
            var v3 = v32.sub(v31);
            if(sA[sA.length-1] != v21) sA[sA.length] = v31;
            if(sB[sB.length-1] != v22) sB[sB.length] = v32;
            if (Vec2.dot(v3,n) <= 0) {
                var ab = v3.sub(v2);
                var t = -Vec2.dot(v2,ab)/Vec2.dot(ab,ab);
                var tmp = v2.add(ab.mul(t));
                returnNormal.set(tmp.x, tmp.y);
                return false;
            }
            // Portal lies on the outside edge of the Minkowski Hull.
            // Return contact information
            if(Vec2.dot(v3.sub(v2),n) <= SIMPLEX_EPSILON || ++maxIterations > 3) {
                var ab = v2.sub(v1);
                var t = Vec2.dot(v1.neg(),ab);
                if (t <= 0.0) {
                    t   = 0.0;
                    returnNormal.set(v1.x, v1.y);
                } else {
                    var denom = Vec2.dot(ab,ab);
                    if (t >= denom) {
                        returnNormal.set(v2.x, v2.y);
                        t   = 1.0;
                    } else {
                        t  /= denom;
                        var t1 = v1.add(ab.mul(t));
                        returnNormal.set(t1.x, t1.y);
                    }
                }
                var s = 1 - t;
                var t1 = v11.mul(s).add(v21.mul(t));
                var t2 = v12.mul(s).add(v22.mul(t));
                point1.set(t1.x, t1.y);
                point2.set(t2.x, t2.y);
                sAB[sAB.length] = v0;
                sAB[sAB.length] = v1;
                sAB[sAB.length] = v2;
                return true;
            }
            // If origin is inside (v1,v0,v3), refine portal
            if (originInTriangle(v0, v1, v3)) {
                v2 = v3;
                v21 = v31;
                v22 = v32;
                continue;
            } else if (originInTriangle(v0, v2, v3)) {
                // If origin is inside (v3,v0,v2), refine portal
                v1 = v3;
                v11 = v31;
                v12 = v32;
                continue;
            }
            return false;
        }
        // This should never happpen.....
        throw "mpr error";
    }
}

class ChainHull
{
    
    public function new() {
    }
    
    private inline function isLeft(P0:Vec2, P1:Vec2, P2:Vec2) {
        return (P1.x - P0.x)*(P2.y - P0.y) - (P2.x - P0.x)*(P1.y - P0.y);
    }

    //===================================================================


    // chainHull_2D(): Andrew's monotone chain 2D convex hull algorithm
    //     Input:  P[] = an array of 2D points
    //                   presorted by increasing x- and y-coordinates
    //             n = the number of points in P[]
    //     Output: H[] = an array of the convex hull vertices (max is n)
    //     Return: the number of points in H[]
    public function compute(P:Array<Vec2>, H:Array<Vec2> )
    {
        // the output array H[] will be used as the stack
        var bot = 0;
        var top = -1;       // indices for bottom and top of the stack
        var i : Int;          // array scan index
        var n = P.length;

        // Get the indices of points with min x-coord and min|max y-coord
        var minmin = 0;
        var minmax = 0;
        var xmin = P[0].x;
        i = 1;
        while(i < n) { 
            if (P[i].x != xmin) break;
            i++;
        }
        minmax = i-1;
        if (minmax == n-1)         // degenerate case: all x-coords == xmin
        {
            H[++top] = P[minmin];
            if (P[minmax].y != P[minmin].y) // a nontrivial segment
                H[++top] = P[minmax];
            H[++top] = P[minmin];           // add polygon endpoint
            return top+1;
        }

        // Get the indices of points with max x-coord and min|max y-coord
        var maxmin, maxmax = n-1;
        var xmax = P[n-1].x;
        i = n-2;
        while(i>=0) {
            if (P[i].x != xmax) break;
            i--;
        }
        maxmin = i+1;

        // Compute the lower hull on the stack H
        H[++top] = P[minmin];      // push minmin point onto stack
        i = minmax;
        while (++i <= maxmin)
        {
            // the lower line joins P[minmin] with P[maxmin]
            if (isLeft( P[minmin], P[maxmin], P[i]) >= 0 && i < maxmin)
                continue;          // ignore P[i] above or on the lower line

            while (top > 0)        // there are at least 2 points on the stack
            {
                // test if P[i] is left of the line at the stack top
                if (isLeft( H[top-1], H[top], P[i]) > 0)
                    break;         // P[i] is a new hull vertex
                else
                    top--;         // pop top point off stack
            }
            H[++top] = P[i];       // push P[i] onto stack
        }

        // Next, compute the upper hull on the stack H above the bottom hull
        if (maxmax != maxmin)      // if distinct xmax points
            H[++top] = P[maxmax];  // push maxmax point onto stack
        bot = top;                 // the bottom point of the upper hull stack
        i = maxmin;
        while (--i >= minmax)
        {
            // the upper line joins P[maxmax] with P[minmax]
            if (isLeft( P[maxmax], P[minmax], P[i]) >= 0 && i > minmax)
                continue;          // ignore P[i] below or on the upper line

            while (top > bot)    // at least 2 points on the upper stack
            {
                // test if P[i] is left of the line at the stack top
                if (isLeft( H[top-1], H[top], P[i]) > 0)
                    break;         // P[i] is a new hull vertex
                else
                    top--;         // pop top point off stack
            }
            H[++top] = P[i];       // push P[i] onto stack
        }
        if (minmax != minmin)
            H[++top] = P[minmin];  // push joining endpoint onto stack

        return top+1;
    }
}

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

    public function add(u:Vec2) {
        return new Vec2(x + u.x, y + u.y);
    }

    public function addAsn(u:Vec2) {
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
    
    public static inline function cross(a:Vec2, b:Vec2) {
        return a.x * b.y - a.y * b.x;
    }
    
    public static inline function dot(a:Vec2, b:Vec2) {
        return a.x * b.x + a.y * b.y;
    }
    
    public static inline function clamp (a:Float, low:Float, high:Float) {
        return Math.max(low, Math.min(a, high));
    }
    
    public static function mul22(A:Mat22, v:Vec2) {
       return new Vec2(dot(v, A.col1), dot(v, A.col2));
    }

    public static function mulXF(T:XForm, v:Vec2) {
        return mul22(T.R, v.sub(T.position));
    }
}

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
class XForm 
{

     /// The position
    public var position : Vec2;
    /// The rotation
    public var R : Mat22;
    
    /**
     * Initialize using a position vector and a rotation matrix.
     * Params:
     *     position = the initial position
     *     R = the initial rotation
     * Returns: a new transform
     */
    public function new(position:Vec2, R:Mat22) {
        this.position = position;
        this.R = R;
    }

    /**
     * Set this to the identity transform.
     */
    public inline function setIdentity() {
        position.zero();
        R.setIdentity();
    }
}
