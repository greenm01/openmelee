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

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.BitmapDataChannel;
import flash.events.Event;
import flash.display.BlendMode;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Point;

import utils.Util;

class Nebula extends Sprite
{

	var bitmapData : BitmapData;
	
	function new () {
		super();
		this.addEventListener(flash.events.Event.ENTER_FRAME,function(_) frameHandler());
		bitmapData = new BitmapData(500, 500);
		addStars();
	}
	
	function frameHandler () {
		this.x++;
	}
	
	function addStars(nbStars:Int=2000, r:Float=1.5, g:Float=0.01, b:Float=1.5, a:Float=0.5) {
		var stageWidth = 500;
		var stageHeight = 500;
		var perlin = new BitmapData(stageWidth, stageHeight, true, 0);
		perlin.perlinNoise(200, 200, 10, Math.round(Math.random() * 100), false, true);
		
		var bd = new BitmapData(stageWidth, stageHeight, true, 0);
		bd.copyChannel(perlin, perlin.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
		bd.colorTransform(bd.rect, new ColorTransform(0.1,2,0.1,1));
		var bStars = new BitmapData(stageWidth, stageHeight, true, 0);
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
		bitmapData.draw(bStars, null, null, BlendMode.LIGHTEN);
		
		//blendMode = BlendMode.LIGHTEN;
		//alpha = 0.8;
		bStars.unlock();
		bitmapData.unlock();
	}
}