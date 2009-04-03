// Ported by Mason Green (zzzzrrr)

import opengl.GL;
import opengl.GLU;
import opengl.GLFW;

import phx.World;
import phx.Body;
import phx.Shape;
import phx.Segment;
import phx.Circle;
import phx.Polygon;
import phx.Vector;

import ships.Ship;
import ships.UrQuan;
import ships.Orz;

class App {
    
	public static var i=0;
    static var world : World;

    static var xmin : Float;
    static var xmax : Float;
    static var ymax : Float;
    static var ymin : Float;
    static var drawCircleRotation : Bool;
    
    public static function createWorld() {
        var size = new phx.col.AABB(-100,-100,100,100);
        var bf = new phx.col.SortedList();
        world = new phx.World(size, bf);
        var planet = new phx.Circle(10.0, new Vector(0,0)); 
        world.addStaticShape(planet);
        world.gravity = new phx.Vector(0,0);
        var ship1 = new UrQuan(world);
        var ship2 = new Orz(world);
    }

    static function drawWorld() {
        GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
        for( b in world.bodies ) {
            drawBody(b);
        }
        drawStaticShapes();
        GLFW.swapBuffers();
    }

    static function drawBody( b : Body ) {
		for( s in b.shapes ) {
			var b = s.aabb;
			if( b.r < xmin || b.b < ymin || b.l > xmax || b.t > ymax )
				continue;
			drawShape(s);
		}
	}

	static function drawShape( s : Shape ) {
			switch( s.type ) {
			case Shape.CIRCLE: drawCircle(s.circle);
			case Shape.POLYGON: drawPoly(s.polygon);
			case Shape.SEGMENT: drawSegment(s.segment);
			}
	}

    static function drawSegment( s : Segment ) {
        //TODO
	}

	static function drawCircle( circ : Circle ) {
        var c = new Vector(circ.tC.x, circ.tC.y);
        var r = circ.r;
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

	static function drawPoly( p : Polygon) {
	    var v = p.tVerts;
        GL.color3(0, 1, 0);
        GL.begin( GL.LINE_LOOP );
        {
            while( v != null ) {
                GL.vertex2(v.x, v.y);
                v = v.next;
            }
        }
        GL.end();
        GL.loadIdentity();
        GL.flush();
    }
    
    static function drawStaticShapes() {
        for( s in world.staticBody.shapes ) {
            drawShape(s);
        }
    }

    static function initGL(left : Float , right : Float, bottom : Float, top : Float, viewCenter : Vector) {
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
	    
        var screenSize = new Vector(800, 600);
        var viewCenter : Vector = new Vector(0,0);
        var zoom = 15;
		var close = false;
		
		var left = -screenSize.x / zoom;
        var right = screenSize.x / zoom;
        var bottom = -screenSize.y / zoom;
        var top = screenSize.y / zoom;

		GLFW.openWindow(Std.int(screenSize.x), Std.int(screenSize.y), 8,8,8, 8,8,0, GLFW.WINDOW );
		initGL(left, right, bottom, top, viewCenter);
		
		GLFW.setWindowSizeFunction( function( w:Int, h:Int ) {
			trace("window resize: "+w+"x"+h );
		});
		GLFW.setWindowCloseFunction( function() {
			trace("window close" );
			close = true;
			return 1;
		});
		GLFW.setWindowRefreshFunction( function() {
			trace("window refresh" );
		});
		GLFW.setKeyFunction( function( a:Int, b:Int ) {
			trace("key: "+a+", "+b );
		});
		GLFW.setCharFunction( function( a:Int, b:Int ) {
			trace("char: "+a+", "+b );
		});
		GLFW.setMouseButtonFunction( function( a:Int, b:Int ) {
			trace("mouseButton: "+a+", "+b );
		});
		GLFW.setMousePosFunction( function( a:Int, b:Int ) {
			trace("mousePos: "+a+", "+b );
		});
		GLFW.setMouseWheelFunction( function( a:Int ) {
			trace("mouseWheel: "+a );
		});
        
        createWorld();
        var Hz = 60;

		while(!close) {
			GLFW.pollEvents();
            world.step(1/Hz, 5);
            drawWorld();
			//neko.Sys.sleep(1./25);
		}
		GLFW.terminate();
		
	}
}
