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

import flash.events.Event;
import flash.display.Sprite;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import phx.col.AABB;

import utils.Util;
import melee.Melee;

class Nebula extends Sprite
{

	public var bitmapData : BitmapData;
	var bStars : BitmapData;
	var background : Bitmap;
	var stageWidth: Int;
	var stageHeight : Int;
	var melee : Melee;
	
	public function new (melee:Melee) {
		super();
		this.melee = melee;
		stageWidth = 500;
		stageHeight = 500;
		bitmapData = new BitmapData(stageWidth, stageHeight, false, 0x00FF0000);
		addStars();
		background = new Bitmap(bitmapData);
		var starField = new Bitmap(bStars);
		addChild(background);
		addChild(starField);
		
	}
	
	public inline function scroll(event:Event) {
		var p = melee.scroll;
		scrollBitmap(bStars,  Std.int(p.x), Std.int(p.y));
		scrollBitmap(bitmapData, -Std.int(p.x*0.5), -Std.int(p.y*0.5));
	}
	
	function addStars(nbStars:Int=2000, r:Float=1.5, g:Float=0.01, b:Float=1.5, a:Float=0.4) {
	
		var perlin = new BitmapData(stageWidth, stageHeight, true, 0);
		perlin.perlinNoise(200, 200, 10, Math.round(Math.random() * 100), true, false);
		
		var bd = new BitmapData(stageWidth, stageHeight, true, 0);
		bd.copyChannel(perlin, perlin.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
		bd.colorTransform(bd.rect, new ColorTransform(0.1,2,0.1,1));

		bStars = new BitmapData(stageWidth, stageHeight, true, 0);
		var star = new flash.display.Shape();
		star.graphics.beginFill(0xFFFFFF, 1);
		
		var i = 0;
		while (i < stageWidth) {
			var j = 0;
			while(j < stageHeight) {
				var decal = bd.getPixel32(i, j) >> 24;
				var t = Util.randomRange(0, 127)+decal;
				var t2 = Util.randomRange(0, 5000-nbStars);
				if((t>t2)) star.graphics.drawCircle(i+Util.randomRange(1,5), j+Util.randomRange(1, 5), Util.randomRange(0.5, 12)/10);
				if (Math.abs(decal) < 5) j += decal;
				j += 5;
			}
			i += 5;
		}
		
		bStars.lock();
		bStars.draw(star);
		bitmapData = perlin;
		bitmapData.lock();
		bitmapData.draw(bd, null, null, BlendMode.NORMAL);
		bitmapData.colorTransform(bitmapData.rect, new ColorTransform(r, g, b, a));
		bStars.unlock();
		bitmapData.unlock();
	}
	
	// function to scroll a seamless bitmap and loop pixels around 
	inline function scrollBitmap(bmd:BitmapData, scrollX:Int, scrollY:Int) {     
		
		var width = bmd.width;
		var height = bmd.height;
		
		// wrap values     
		while(scrollX > width) scrollX -= width;     
		while(scrollX < -width) scrollX += width;     
		while(scrollY > height) scrollY -= height;     
		while(scrollY < -height) scrollY += height;   
		      
		// the 4 edges of the bitmap     
		var xPixels = Math.abs(scrollX), yPixels = Math.abs(scrollY);     
		var rectR:Rectangle = new Rectangle(width-xPixels,0,xPixels,height);     
		var rectL:Rectangle = new Rectangle(0,0,xPixels,height);     
		var rectT:Rectangle = new Rectangle(0,0,width,yPixels);     
		var rectB:Rectangle = new Rectangle(0,height-yPixels,width,yPixels);     
		var pointL:Point = new Point(0,0);     
		var pointR:Point = new Point(width-xPixels,0);     
		var pointT:Point = new Point(0,0);     
		var pointB:Point = new Point(0,height-yPixels);         
		var tmp = new BitmapData(width,height,bmd.transparent,0x000000); 
		        
		// copy column, scroll, paste     
		scrollX > 0 ? tmp.copyPixels(bmd,rectR, pointL) : tmp.copyPixels(bmd,rectL, pointR);     
		bmd.scroll(scrollX,0);     
		scrollX > 0 ? bmd.copyPixels(tmp,rectL, pointL) : bmd.copyPixels(tmp,rectR, pointR);  
		       
		// copy row, scroll, paste     
		scrollY > 0 ? tmp.copyPixels(bmd,rectB, pointT) : tmp.copyPixels(bmd,rectT, pointB);     
		bmd.scroll(0,scrollY);     
		scrollY > 0 ? bmd.copyPixels(tmp,rectT, pointT) : bmd.copyPixels(tmp,rectB, pointB);         
		tmp.dispose(); 
	}
}