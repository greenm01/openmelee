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
package hud;

import flash.accessibility.Accessibility;
import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BevelFilter;
import flash.geom.Vector3D;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import phx.Circle;
import phx.Vector;
import phx.Circle;
import phx.Polygon;

import render.RenderMelee;
import ships.Ship;
import ships.Orz;

class HUD extends Sprite
{

	var orz : Orz;
	public var ship1: Ship;
	var ship1Icon : Bitmap;
	var s1 : flash.display.Shape;
	var s1Special : flash.display.Shape;
	var ship1Bat : Sprite;
	var bat1Pos : Vector;
	var ship1Crew : Sprite;
	var crew1Pos : Vector;
	var ship1Title : TextField;
	var crewBat1 : TextField;
	
	public var ship2: Ship;
	var ship2Icon : Bitmap;
	var s2 : flash.display.Shape;
	var ship2Bat : Sprite;
	var bat2Pos : Vector;
	var ship2Crew : Sprite;
	var crew2Pos : Vector;
	var ship2Title : TextField;
	var crewBat2 : TextField;

	var white : Int;
	var green : Int;
	var red : Int;
	var blue : Int;
	var limeGreen : Int;

	public function new(s1:Ship, s1bm:Bitmap, s2:Ship, s2bm:Bitmap) {
		super();
		ship1 = s1;
		ship1Icon = s1bm;
		ship2 = s2;
		ship2Icon = s2bm;
		white = 0xFFFFFF;
		green = 0x33CC11;
		red = 0xFF0000;
		blue = 0x6633FF;
		limeGreen = 0x00FF00;
		crew1Pos =  new Vector(515, 152);
		bat1Pos =  new Vector(625, 152);
		crew2Pos = new Vector(515, 402);
		bat2Pos =  new Vector(625, 402);
		init();
	}
	
	function init() {
		// Draw HUD menu
		var g = graphics;
		g.lineStyle(1.0, 0x999999);
		g.beginFill(0x333333, 1);
		g.drawRect(500, 0, 150, 500);
		g.endFill();

		g.moveTo(503, 3);
		g.lineTo(503, 3);
		g.lineTo(647, 3);
		g.lineTo(647, 497);
		g.lineTo(503, 497);
		g.lineTo(503, 3);
		
		g.moveTo(503, 247);
		g.lineTo(503, 247);
		g.lineTo(647, 247);

		// Ship 1
		print(new Vector(505, 5), ship1.name, white);
		print(new Vector(505, 125), ship1.captain, white);
		print(new Vector(505, 155), "Crew                     Battery", white);
		
		addChild(ship1Icon);
		ship1Icon.x = 515;
		ship1Icon.y = 175;
		ship1Icon.scaleY = 2.25;
		ship1Icon.scaleX = 2.25;
	
		ship1Crew = new Sprite();
		var cap = ship1.crewCapacity;
		updateState(ship1Crew, cap, cap, crew1Pos, green);
		addChild(ship1Crew);
		
		ship1Bat = new Sprite();
		cap = ship1.batteryCapacity;
		updateState(ship1Bat, cap, cap, bat1Pos, red);
		addChild(ship1Bat);
		
		s1 = new flash.display.Shape();
		s1.x = 575.0;
		s1.y = 85.0;
		s1.rotation = -90;
		s1.scaleX = s1.scaleY = 20.0;
		RenderMelee.drawBody(s1.graphics, ship1.rBody, blue);
		addChild(s1);
		s1.filters = [new BevelFilter(2)]; 
		
		orz = cast(ship1, Orz);
		s1Special = new flash.display.Shape();
		s1Special.x = 575.0;
		s1Special.y = 85.0;
		s1Special.rotation = -90;
		RenderMelee.drawBody(s1Special.graphics, ship1.secondWep.rBody, red);
		s1Special.scaleX = s1Special.scaleY = 20.0;
		addChild(s1Special);
		s1Special.filters = [new BevelFilter(2)]; 
		
		// Ship 2
		print(new Vector(505, 249), ship2.name, white);
		print(new Vector(505, 385), ship2.captain, white);
		print(new Vector(505, 405), "Crew                     Battery", white);
		
		addChild(ship2Icon);
		ship2Icon.x = 515;
		ship2Icon.y = 425;
		ship2Icon.scaleY = 2.25;
		ship2Icon.scaleX = 2.25;
		
		ship2Crew = new Sprite();
		cap = ship2.crewCapacity;
		updateState(ship2Crew, cap, cap, crew2Pos, green);
		addChild(ship2Crew);
		
		ship2Bat = new Sprite();
		cap = ship2.batteryCapacity;
		updateState(ship2Bat, cap, cap, bat2Pos, red);
		addChild(ship2Bat);

		s2 = new flash.display.Shape();
		s2.x = 575.0;
		s2.y = 340.0;
		s2.rotation = -90;
		s2.scaleX = s2.scaleY = 20.0;
		RenderMelee.drawBody(s2.graphics, ship2.rBody, green);
		s2.graphics.endFill();
		addChild(s2);
		s2.filters = [new BevelFilter(2)]; 
	}
	
	public inline function update(event:Event) {
		updateState(ship1Crew, ship1.crewCapacity, ship1.crew, crew1Pos, green);
		updateState(ship1Bat, ship1.batteryCapacity, ship1.battery, bat1Pos, red);
		updateState(ship2Crew, ship2.crewCapacity, ship2.crew, crew2Pos, green);
		updateState(ship2Bat, ship2.batteryCapacity, ship2.battery, bat2Pos, red);
		updateSpecial();
	}
	
	inline function updateState(sprite:Sprite, max:Int, num:Int, pos:Vector, color:Int) {
		var p = pos.clone();
		var g = sprite.graphics;
		g.clear();
		g.lineStyle(1);
		g.beginFill(0x000000, 1);
		var height = (max * 0.5) * 5 + 2;
		g.drawRect(p.x, p.y - height, 13, height);
		p.x += 2;
		p.y -= 4;
		var c = 0;
		for (i in 0...Math.ceil(num*0.5)) {
			g.lineStyle(1.0, color);
			g.beginFill(color, 1.0);
			g.drawRect(p.x, p.y - 5 * i, 4, 2);
			if (++c == num) break;
			g.lineStyle(1.0, color);
			g.beginFill(color, 1.0);
			g.drawRect(p.x + 6, p.y - 5 * i, 4, 2);
			c++;
		}
	}
	
	inline function print(pos:Vector, text:String, color:Int) {
		var message = new TextField();
		message.text = text;
		message.textColor = color;
		message.x = pos.x;
		message.y = pos.y;
		message.width = 140;
		message.height = 18;
		message.autoSize = TextFieldAutoSize.CENTER;
		addChild(message);
	}
	
	inline function updateSpecial() {
		s1Special.rotation = (orz.secondWep.rBody.a - orz.rBody.a - Math.PI/2) * 57.2957795;
	}
	
}
