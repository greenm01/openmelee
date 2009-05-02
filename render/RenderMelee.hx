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

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.BitmapDataChannel;
import flash.events.Event;
import flash.events.KeyboardEvent;

import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BlendMode;

import phx.World;
import phx.Body;
import phx.Shape;
import phx.Polygon;
import phx.Circle;
import phx.Vector;
import phx.col.AABB;

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

class RenderMelee
{
	
	var nebula : Nebula;
	var g : Graphics;
	
	public var shape : CX;
	public var kzerZa : CX;
	public var nemesis : CX;
	public var planet : CX;
	
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
    
	var melee : Melee;
	var d : flash.display.Shape;
	
	var oldPos : Vector;
	
    public function new(melee:Melee) {

        this.melee = melee;
        scale = Vector.init();

		oldPos = new Vector(0,0);
		
		var stage = melee.stage;
		stage.addEventListener(Event.ENTER_FRAME,function(_) melee.loop());
		stage.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent) melee.human.onKeyDown(e.keyCode));
		stage.addEventListener(KeyboardEvent.KEY_UP,function(e:KeyboardEvent) melee.human.onKeyUp(e.keyCode));
		
        zoom = 20;
        running = true;
        world = melee.world;
        ship1 = melee.ship1;
        ship2 = melee.ship2;
        viewCenter = new Vector(0, 0);
        screenSize = new Vector(800, 600);
        
        var color = new Color(1.0, 0.0, 0.0);
        shape = { lineSize : 1.0, line : 0xFF0000, fill : 0xFF0000, alpha : 0.25 };
        color = new Color(0.0, 0.0, 0.5);
		planet = { lineSize : 2.0, line : 0x333333, fill : color.getColor(), alpha : 1.0 };
		nemesis = { lineSize : 1.0, line : 0x6633FF, fill : 0x6633FF, alpha : 0.50 };
		kzerZa = { lineSize : 1.0, line : 0x00FF00, fill : 0x00FF00, alpha : 0.50 };
		
		nebula = new Nebula();
		melee.addChild(nebula);
		d = new flash.display.Shape();
		g = d.graphics;
		melee.addChild(d);
    }
    
    public function update() {
		g.clear();
        draw();
    }

    function selectColor( s : Shape ) {
		if (s.body == ship1.rBody) return nemesis;
		if (s.body == ship2.rBody) return kzerZa;
		if (s.body == world.staticBody) return planet;
		return shape;
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
		if(p.x > 500 || p.y > 500) return;
		g.drawCircle(p.x, p.y, c.r*zoom);
		if( drawCircleRotation ) {
			g.moveTo(c.tC.x, c.tC.y);
			g.lineTo(c.tC.x + c.body.rcos * c.r, c.tC.y + c.body.rsin * c.r);
		}
	}

    function drawPoly( p : Polygon ) {
		var v = p.tVerts;
		var f = transform(v);
		if(f.x > 500 || f.y > 500) return;
		g.moveTo(f.x, f.y);
		while( v != null ) {
		    f = transform(v);
			g.lineTo(f.x, f.y);
			v = v.next;
		}
		f = transform(p.tVerts);
		g.lineTo( f.x, f.y);
	}
    
    function drawShape(s : Shape) {
        var c = selectColor(s);
        if( begin(c) ) {
            switch( s.type ) {
                case Shape.CIRCLE: drawCircle(s.circle);
                case Shape.POLYGON: drawPoly(s.polygon);
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
		
		var point1 : Vector;
        var point2 : Vector;
		
		if(ship1 == null) {
			point1 = melee.planet.state.pos;
		} else {
			point1 = new Vector(ship1.rBody.x, ship1.rBody.y);
		}
	
		if(ship2 == null) {
			point2 = melee.planet.state.pos;
		} else {
			point2 = new Vector(ship2.rBody.x, ship2.rBody.y);
		}
			
        var range = point1.minus(point2);
        var dist = range.length();
        zoom = Util.clamp(500/(dist+10), 1.0, 25.0);
        viewCenter = point1.minus(range.mult(0.5));
		
		var x = (oldPos.x - point1.x) * 5.0; 
		var y = -(oldPos.y - point1.y) * 5.0;
		nebula.scrollStars(x, y);
		oldPos = point1.clone();
		
        dist = Util.clamp(dist, 50, 400);
        var left = (viewCenter.x - dist);
        var right = (viewCenter.x + dist);
        var bottom = (viewCenter.y + dist);
        var top = (viewCenter.y - dist);
        
        var aabb = new AABB(left, top, right, bottom);
        
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
    }
    
    inline function transform(v:Vector) {
        var lp = localPoint(v);
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
        var x = 250.0;
        var y = 250.0;
		var col1 = new Vector(1,0);
		var col2 = new Vector(0,1);
		var point = new Vector((col1.x * v.x + col2.x * v.y)*zoom, (col1.y * v.x + col2.y * v.y)*zoom);
		var pos = new Vector(x, y);
		return pos.plus(point);
    }
}