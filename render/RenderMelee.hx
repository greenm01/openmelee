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
import flash.filters.BevelFilter;
import flash.filters.DropShadowFilter;

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
    
	public var melee : Melee;
	var oldPos : Vector;
	
    public function new(melee:Melee) {
		
        this.melee = melee;
        scale = Vector.init();
		viewCenter = new Vector(0, 0);
        screenSize = new Vector(800, 600);
		oldPos = new Vector(0, 0);
		zoom = 20;
		
        var color = new Color(1.0, 0.0, 0.0);
        shape = { lineSize : 1.0, line : null, fill : 0xFF0000, alpha : 1.0 };
        color = new Color(0.0, 0.0, 0.5);
		nemesis = { lineSize : 1.0, line : null, fill : 0x6633FF, alpha : 0.75 };
		planet = { lineSize : 2.0, line : 0x333333, fill : color.getColor(), alpha : 1.0 };
		kzerZa = { lineSize : 1.0, line : null, fill : 0x00FF00, alpha : 0.75 };

		world = melee.world;
        ship1 = melee.ship1;
        ship2 = melee.ship2;
    }

    static inline function drawShape(g:Graphics, s:phx.Shape, color:Int) {
		g.lineStyle(1/20, color);
		g.beginFill(color, 0.5);
		switch( s.type ) {
			case phx.Shape.CIRCLE: drawCircle(g, s.circle);
			case phx.Shape.POLYGON: drawPoly(g, s.polygon);
		}
		g.endFill();
    }
	
	static inline function drawCircle(g:Graphics, c:Circle) {
		var p = c.c;
		g.moveTo(p.x, p.y);
		g.drawCircle(p.x, p.y, c.r);
	}
	
	static inline function drawPoly(g:Graphics, p:Polygon) {
		var v = p.verts;
		g.moveTo(v.x, v.y);
		while ( v != null ) {
			g.lineTo(v.x, v.y);
			v = v.next;
		}
		v = p.verts;
		g.lineTo(v.x, v.y);
	}
    
    public static inline function drawBody(g:Graphics, b : Body, color:Int ) {
		for( s in b.shapes ) {
			drawShape(g, s, color);
		}
	}
	
    public inline function update() {
		
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
        var dist = range.length() + 10;
        zoom = Util.clamp(500/(dist), 1.0, 25.0);
        viewCenter = point1.minus(range.mult(0.5));
		
		var x = (oldPos.x - point1.x) * 5.0; 
		var y = -(oldPos.y - point1.y) * 5.0;
		melee.scroll.set(x, y);
		oldPos = point1.clone();
		
        dist = Util.clamp(dist, 50, 400);
        var left = (viewCenter.x - dist);
        var right = (viewCenter.x + dist);
        var bottom = (viewCenter.y + dist);
        var top = (viewCenter.y - dist);
		
        var aabb = new AABB(left, top, right, bottom);
        
        // Update bodies
        for (i in 0...melee.gameObjects.numChildren) {
			var o = cast(melee.gameObjects.getChildAt(i), ships.GameObject);
            for(s in o.rBody.shapes) {
                if (aabb.intersects2(s.aabb)) {
                    o.visible = true;
					var trans = transform(o.state.pos);
					o.x = trans.x;
					o.y = trans.y;
					o.rotation = -o.rBody.a * 57.2957795;
					o.scaleX = o.scaleY = zoom;
					break;
                } else {
					o.visible = false;
					break;
				}
            }
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