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

import opengl.GL;
import opengl.GLU;
import opengl.GLFW;

import haxmel.utils.Vec2;
import haxmel.physics.ChainHull;
import haxmel.physics.Mpr;

enum ShapeType {
    TRIANGLE;
    QUAD;
    PENTAGON;
    HEXAGON;
    CIRCLE;
}

class MprTest {
    
	public static var i=0;
    static var system : System;
    
    static function drawScene() {
        GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
        drawBullsEye();
        drawMinkowskiHull();
        drawContactPoints();
        for( b in system.bodies) {
            drawShape(b);
        }
        GLFW.swapBuffers();
    }

	static function drawShape( b : RigidBody ) {
        switch(b.type) {
            case Shape.CIRCLE: drawCircle(b);
            case Shape.POLYGON: drawPoly(b);
        }
	}

	static function drawCircle( circle : RigidBody ) {
        var c = circle.pos;
        var r = circle.radius;
        var segs = 20;
        var coef = 2.0 * Math.PI / segs;
        var theta = circ.body.a;
        GL.begin(GL.LINE_STRIP); 
        {
            for (n in 0...segs+1) {
                var rads = n * coef;
                var x = r * Math.cos(rads + theta) + c.x;
                var y = r * Math.sin(rads + theta) + c.y;
                GL.vertex2(x, y);
            }
            GL.vertex2(c.x, c.y);
        } 
        GL.end();
        GL.loadIdentity();
        GL.flush();
	}

	static function drawPoly( polygon : RigidBody) {
        GL.color3(0, 1, 0);
        GL.begin( GL.LINE_LOOP );
        {
            for( v in polygon.vW) {
                GL.vertex2(v.x, v.y);
                v = v.next;
            }
        }
        GL.end();
        GL.loadIdentity();
        GL.flush();
    }
    
    static function drawContactPoints() {
        if (system.penetrate) {
            GL.loadIdentity();
            GL.translate(50,50,0);
            GL.color3(1,1,0);
            GL.begin(GL_POINTS);
            {
                GL.vertex2(system.returnNormal.x, system.returnNormal.y);
            }
            GL.end();
            GL.loadIdentity();
            glPointSize(10);
            GL.begin(GL_POINTS);
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
        GL.begin(GL_LINES);
        {
            GL.vertex2(50,52.5);
            GL.vertex2(50,47.5);
            GL.vertex2(47.5,50);
            GL.vertex2(52.5,50);
        }
        GL.end();
    }
    
    static function drawMinkowskiHull() {
        GL.begin(GL_LINE_STRIP);
        {
            var k = 0;
            for(m in system.minkHull) {
                if (m.x != 0 && m.y != 0) {
                    GL.vertex2(m.x, m.y);
                    k++;
                }
            }
        }
        GL.end();
    }
    
    static function drawSimplex() {
        GL.loadIdentity();
        GL.translate(50,50,0);
        GL.color3(1,1,0);
        GL.begin(GL_LINE_LOOP);
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
	    
        var screenSize = new Vec2(800, 600);
        var viewCenter : Vec2 = new Vec2(0,0);
        var zoom = 15;
		var close = false;
		
		var left = -screenSize.x / zoom;
        var right = screenSize.x / zoom;
        var bottom = -screenSize.y / zoom;
        var top = screenSize.y / zoom;

		GLFW.openWindow(Std.int(screenSize.x), Std.int(screenSize.y), 8,8,8, 8,8,0, GLFW.WINDOW );
		initGL(left, right, bottom, top, viewCenter);
		
		GLFW.setKeyFunction(onKey);
        
        system = new System();
        createWorld();
        var Hz = 60;

		while(!close) {
			GLFW.pollEvents();
            system.step(1/Hz, 5);
            drawWorld();
		}
		GLFW.terminate();
		
	}
	
	static var onKey = function(key:Int, state:Int) {
	     // Key pressed
		if (state == 257 || state == 1) {
			switch (key) {
			    case GLFW.KEY_ESC:
			        close = true;
                case GLFW.KEY_RIGHT:
                    system.rb[1].vel.x += 5;
                case GLFW.KEY_LEFT:
                    system.rb[1].vel.x -= 5;
                case GLFW.KEY_UP:
                    system.rb[1].vel.y += 5;
                case GLFW.KEY_DOWN:
                    system.rb[1].vel.y -= 5;
                case GLFW.KEY_SPACE:
                    system.rb[1].vel.x = 0;
                    system.rb[1].vel.y = 0;
                    system.rb[1].omega = 0;
                case GLFW.KEY_RSHIFT:
                    system.rb[1].omega += 0.01;
                case GLFW.KEY_RETURN:
                    system.rb[1].omega -= 0.01;
                case GLFW.KEY_d:
                    system.rb[0].vel.x += 5;
                case GLFW.KEY_a:
                    system.rb[0].vel.x -= 5;
                case GLFW.KEY_w:
                    system.rb[0].vel.y += 5;
                case GLFW.KEY_s:
                    system.rb[0].vel.y -= 5;
                case GLFW.KEY_e:
                    system.rb[0].omega += 0.01;
                case GLFW.KEY_q:
                    system.rb[0].omega -= 0.01;
                case GLFW.KEY_c:
                    system.rb[0].vel.x = 0;
                    system.rb[0].vel.y = 0;
                    system.rb[0].omega = 0;
                case GLFW.KEY_p:
                    system.rb[0].q = 0;
                    system.rb[1].q = 0;
                case GLFW.KEY_LEFTBRACKET:
                    if (system.shape1 == 5) system.shape1 = 1;
                    else if(system.shape1 == 4) system.shape1 = 5;
                    else system.shape1++;
                    system.spawn(1);
                case GLFW.KEY_RIGHTBRACKET:
                    if (system.shape2 == 5) system.shape2 = 1;
                    else if(system.shape2 == 4) system.shape2 = 5;
                    else system.shape2++;
                    system.spawn(2);
            }
        } else {
            // Key Released
        }
    }
}

class System
{
    static var SCALE = 5;            // Poltgon scale factor
    static var CIRCLE_SEGS = 50;
    var rb : Array<Body>;

    var range : Vec2;
    var cp1 : Vec2;
    var cp2 : Vec2;

    var minkSum : Array<Vec2>;
    var minkHull : Array<Vec2>;
    var chainHull : ChainHull;
    
    var penetrate : Bool;

    // CSO
    var sA : FastList<Vec2>;           
    var sB : FastList<Vec2>;                        
    var sAB : FastList<Vec2>;                       

    var point1 : Vec2;
    var point2 : Vec2;
    var returnNormal : Vec2;

    public function new() {
        
        rb = new Array();
        sA = new FastList();
        sB = new FastList();
        sAB = new FastList();
        chainHull = new ChainHull();
        
        rb[0] = new RigidBody(ShapeType.POLYGON);
        rb[0].pos = new Vec2(40.0, 20.0);
        rb[0].vel = new Vec2(0.0, 0.0);
        rb[0].omega = 0.01;

        rb[1] = new RigidBody(ShapeType.CIRCLE);
        rb[1].pos = new Vec2(40.0, 40.0);
        rb[1].vel = new Vec2(0.1, 0.0);
        rb[1].omega = 0.01;
    }

    public function step(dt:Float) {
        rb[0].update(dt);
        rb[1].update(dt);
        // Clear display infromation
        sA = new FastList();
        sB = new FastList();
        sAB = new FastList();
        point1 = new Vec2(0,0);
        point2 = new Vec2(0,0);

        penetrate = collideAndFindPoint(rb[0], rb[1], returnNormal, point1, point2, sAB, sA, sB);
        minkDiff();

    }

    // Change Polygon Shape
    public function spawn(hull:ShapeType) {
        if (hull == 1) rb[0].shape(shape1);
        else rb[1].shape(shape2);
    }

    // Calculate Minkowski Difference for display
    function minkDiff()	{							                    

        minkSum = new Array();
        var i = 0;
        for(rb1 in rb[1].vertex) {
            for(rb2 in rb[0].vertex) {
                minkSum[i].x = rb1.x - rb2.x;
                minkSum[i++].y = rb1.y - rb2.y;
            }
        }

        minkSum.sort(function(v1, v2) {
            if(v1.x == v2.x && v1.y == v2.y) return 0;
            if(v1.x < v2.x || v1.y < v2.y) return -1;
            return 1;
        });
        // Find Minkowski Hull
        minkHull = new Array();
        chainHull.compute(minkSum, minkHull);					            
    }
}

private class RigidBody
{
    var vL : FastList<Vec2>;
    var vW : FastList<Vec2>;
    
    // State variables
    // Position of center of mass
    public var pos : Vec2;	
    // Rotation position				
    var q : Float;					

    // Derived quantities (auxiliary variables)
    // linear velocity
    var vel : Vec2;					
    // angular velocity
    var omega : Float;				

    var type : ShapeType;
    var radius : Float;

    public function new(type:ShapeType) {
        this.type = type;
        shape(type);
        q = 0.0001;
        transform();
    }

    private function shape(hull:ShapeType) {
        type = hull;
        switch (hull)
        {
        case ShapeType.TRIANGLE:		
            vL = new FastList();
            vL.add(new Vec2(0,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
        case ShapeType.QUAD:		
            vL = new FastList();
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1,-1));
            vL.add(new Vec2(-1,-1));
            vL.add(new Vec2(-1,1));
        case ShapeType.PENTAGON:		
            vL = new FastList();
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(2,0));
            vL.add(new Vec2(0,-2));
            vL.add(new Vec2(-2,0));
            vL.add(new Vec2(-1,1));
        case ShapeType.HEXAGON:		
            vL = new FastList();
            vL.add(new Vec2(1,1));
            vL.add(new Vec2(1.5,0));
            vL.add(new Vec2(0.5,-3));
            vL.add(new Vec2(-0.5,-3));
            vL.add(new Vec2(-1.5,0));
            vL.add(new Vec2(-1,1));
        case ShapeType.CIRCLE:		
            radius = 1.5;
            vL = null;
        }
    }

    public function update(dt:Float) {
        pos.x += vel.x*dt;
        pos.y += vel.y*dt;
        q += omega*dt;
        transform();
    }

    private function transform() {
        // Update world coordinates
        //Polar rotation to cartesian coordinates
        var degrees = q * 180.0/Math.PI;			

        while (degrees > 360) degrees -= 360;
        while (degrees < -360) degrees += 360;

        var cd = Math.cos(degrees);
        var sd = Math.sin(degrees);

        vW = new FastList();
        for(v in vL) {
            var x = pos.x + SCALE*(v.x*cd + v.y*sd);
            var y = pos.y + SCALE*(-v.x*sd + v.y*cd);
            vW.add(new Vec2(x,y));
        }
    }

    private function support(n:Vec2) {
        var r = new Vec2(0,0);
        if(type == ShapeType.CIRCLE) {
            r = n.getNormal.mul(radius).mul(SCALE);
            r = r.add(pos);
        } else {
            var i = vW.length-1;
            r = vW[i--];
            while (i>=0)
            {
                if ( (vW[i] - r) * n >= 0 )
                {
                    r = vW[i];
                }
                i--;
            }
        }
        return r;
    }
}
