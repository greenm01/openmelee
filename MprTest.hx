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

import utils.Vec2;
import physics.ChainHull;
import physics.Mpr;
import physics.RigidBody;

class MprTest {
    
	public static var i=0;
    static var system : System;
    static var close : Bool;
    
    static var closestFeatures : Bool = false;
    static var closestPoints : Bool = true;
    
    static function drawScene() {
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
        var segs = 20;
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
