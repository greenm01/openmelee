/* OpenMelee
 * Copyright (c) 2009, Mason Green 
 * http://github.com/zzzzrrr/openmelee
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
 * * Neither the name of OpenMelee nor the names of its contributors may be
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
package render;

import flash.display.MovieClip;
import flash.text.TextField;
import flash.display.Graphics;

import phx.World;
import phx.Body;
import phx.Shape;
import phx.Polygon;
import phx.Circle;
import phx.Vector;

import melee.Melee;
import ships.Ship;
import utils.Util;

import render.Color;

typedef CX = {
	public var lineSize : Float;
	public var line : Null<Int>;
	public var fill : Null<Int>;
	public var alpha : Float;
}

class RenderFlash
{

    var root : MovieClip;
	var tf : TextField;
	var g : Graphics;
	var defaultFrameRate : Float;
	
	public var shape : CX;
	public var staticShape : CX;
	public var sleepingShape : CX;
	public var boundingBox : CX;
	public var contact : CX;
	public var sleepingContact : CX;
	public var contactSize : CX;
	
    static var MAX_CIRCLE_RES = 32;
	var zoom : Float;
	var scale : Vector;
	
	var viewCenter : Vector;
    var world : World;
    var screenSize : Vector;
    var drawCircleRotation : Bool;
    
    var ship1 : Ship;
    public var ship2 : Ship;
    static public var running : Bool;
    
    public function new(melee:Melee) {
        
        scale = Vector.init();

        this.root = melee.om.root;
        g = root.graphics;
        defaultFrameRate = root.stage.frameRate;

        drawCircleRotation = false;
		
		var stage = root.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.addEventListener(flash.events.Event.ENTER_FRAME,function(_) melee.loop());
		//stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE,function(_) mouseMove(root.mouseX, root.mouseY));
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,function(e:flash.events.KeyboardEvent) melee.human.onKeyDown(e.keyCode));
		stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,function(e:flash.events.KeyboardEvent) melee.human.onKeyUp(e.keyCode));
		
        zoom = 20;
        running = true;
        world = melee.world;
        ship1 = melee.ship1;
        ship2 = melee.ship2;
        viewCenter = new Vector(0, 0);
        screenSize = new Vector(800, 600);
        
        var color = new Color(1.0, 0.0, 0.0);
        shape = { lineSize : 1.0, line : color.getColor(), fill : color.getColor(), alpha : 0.25 };
        color = new Color(0.0, 0.0, 0.5);
		staticShape = { lineSize : 2., line : 0x333333, fill : color.getColor(), alpha : 0.5 };
		sleepingShape = { lineSize : 2., line : 0x333333, fill : 0x7FECEC, alpha : 1. };
		boundingBox = { lineSize : 0., line : null, fill : null, alpha : 1. };
		contact = { lineSize : 1., line : null, fill : null, alpha : 1. };
		sleepingContact = { lineSize : 1., line : null, fill : null, alpha : 1. };
		contactSize = { lineSize : 1., line : null, fill : null, alpha : 1. };
		
    }
    
    function mouseMove(x:Float, y:Float) {
        trace(x + "," + y);
    }
    
    public function update() {
        g.clear();
        draw();
    }

    function selectColor( s : Shape ) {
		return s.body.isStatic ? staticShape : (s.body.island != null && s.body.island.sleeping ? sleepingShape : shape);
	}
	
	function begin( c : CX ) {
		if( c == null || (c.line == null && c.fill == null) ) return false;
		if( c.line == null ) g.lineStyle() else g.lineStyle(c.lineSize,c.line);
		if( c.fill != null ) g.beginFill(c.fill,c.alpha);
		return true;
	}

	function end( c : CX ) {
		if( c.fill != null ) g.endFill();
	}
	
    function drawCircle( c : Circle ) {
        var p = transform(c.tC);
		g.drawCircle(p.x, p.y, c.r*zoom);
		if( drawCircleRotation ) {
			g.moveTo(c.tC.x, c.tC.y);
			g.lineTo(c.tC.x + c.body.rcos * c.r, c.tC.y + c.body.rsin * c.r);
		}
	}

    function drawPoly( p : Polygon ) {
		var v = p.tVerts;
		var f = transform(v);
		g.moveTo(f.x, f.y);
		while( v != null ) {
		    f = transform(v);
			g.lineTo(f.x, f.y);
			//trace(f.x + "," + f.y);
			v = v.next;
		}
		v = p.tVerts;
		f = transform(v);
		g.lineTo( f.x, f.y);
	}
    
    function drawShape(s : Shape) {
        var c = selectColor(s);
        if( begin(c) ) {
            switch( s.type ) {
                case Shape.CIRCLE: drawCircle(s.circle);
                case Shape.POLYGON: drawPoly(s.polygon);
                //case Shape.SEGMENT: drawSegment(s.segment);
            }
            end(c);
        }
    }
    
    public function drawBody( b : Body ) {
		for( s in b.shapes ) {
			drawShape(s);
		}
	}
   
    function draw() {
    
        var point1 = new Vector(ship1.rBody.x, ship1.rBody.y);
        var point2 = new Vector(ship2.rBody.x, ship2.rBody.y);
        var range = point1.minus(point2);
        var dist = range.length();
        zoom = Util.clamp(500/dist, 1.0, 25.0);
        viewCenter = point1.minus(range.mult(0.5));

        //trace(zoom);
        
        dist = Util.clamp(dist, 20, 400);
        var left = (viewCenter.x - dist);
        var right = (viewCenter.x + dist);
        var bottom = (viewCenter.y + dist);
        var top = (viewCenter.y - dist);
        
        var aabb = new phx.col.AABB(left, top, right, bottom);
        
        /*
        var c = sleepingShape;
        var scale = 1.0;
        begin(c);
        g.moveTo(left*scale, bottom*scale);
        g.lineTo(right*scale, bottom*scale);
        g.lineTo(right*scale, top*scale);
        g.lineTo(left*scale, top*scale);
        g.lineTo(left*scale, bottom*scale);
        end(c);
        */
        
        var d = false;
        // Draw static bodies
        for(s in world.staticBody.shapes) {
            if(aabb.intersects2(s.aabb)) {
                d = true;
                break;
            }
        }
        if(d) {
            drawBody(world.staticBody);
        }
        
        // Draw dynamic bodies
        d = false;
        for(b in world.bodies) {
            for(s in b.shapes) {
                if(aabb.intersects2(s.aabb)) {
                    d = true;
                }
            }
            if(d) {
                drawBody(b);
            }
            d = false;
        }
        
        /*
        GL.loadIdentity();
        GL.matrixMode(GL.PROJECTION);
        GL.loadIdentity();
        GLU.ortho2D(left, right, bottom, top);
        GL.translate(-viewviewCenter.x, -viewviewCenter.y, 0);
        GL.matrixMode(GL.MODELVIEW);
        GL.disable(GL.DEPTH_TEST);
        GL.loadIdentity();
        GL.clear(GL.COLOR_BUFFER_BIT);
        */
        
        
        
        /*
        // Draw dynamic bodies
        for (b in world.bodies) {
            drawBody(b);
        }
        {
            // Draw the world bounds
            var wb = world.box;
            var color : Color = {r : 0.3, g : 0.9, b : 0.9};        
            var vs = new Array();
            vs.push(new Vector(wb.l, wb.b));
            vs.push(new Vector(wb.r, wb.b));
            vs.push(new Vector(wb.r, wb.t));
            vs.push(new Vector(wb.l, wb.t));
            GL.color3(color.r, color.g, color.b);
            GL.begin( GL.LINE_LOOP );
            {
                for(v in vs) {
                    GL.vertex2(v.x, v.y);
                }
            }
            GL.end();
            GL.loadIdentity();
            GL.flush();
        }
        */
    }
    
    inline function transform(v:Vector) {
        var lp = localPoint(v);
        //lp.x *= 10;
        //lp.y *= 10;
        return(worldPoint(lp));
    }
    
    inline function localPoint(v:Vector) {
        var a = Math.PI;
		var d = new Vector(v.x - viewCenter.x, v.y - viewCenter.y);
		var col1 = new Vector(1,0);
		var col2 = new Vector(0,1);
		return new Vector(d.dot(col1), -d.dot(col2));
    }
    
    inline function worldPoint(v:Vector) {
        var x = 400.0;
        var y = 250.0;
		var col1 = new Vector(1,0);
		var col2 = new Vector(0,1);
		var point = new Vector((col1.x * v.x + col2.x * v.y)*zoom, (col1.y * v.x + col2.y * v.y)*zoom);
		var pos = new Vector(x, y);
		return pos.plus(point);
    }
}
