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
package melee;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.geom.Vector3D;
import flash.events.Event;
import flash.events.KeyboardEvent;

import haxe.FastList;

import phx.col.AABB;
import phx.col.SortedList;
import phx.World;
import phx.Body;
import phx.Vector;
import phx.WorldContactListener;

import ships.Ship;
import ships.GameObject;
import ships.UrQuan;
import ships.Orz;
import ships.Planet;
import ships.Asteroid;
import ships.Marine;

import ai.AI;
import ai.Human;
import render.RenderMelee;
import render.Nebula;
import hud.HUD;
import utils.Set;

class Melee extends Sprite
{
    static var NUM_ASTROIDS : Int = 5;
	public var destroyList : Set<Body>;
    var timeStep : Float;
    var allowSleep : Bool;
    public var render : RenderMelee;

    public var human : Human;
    public var ship1 : Ship;
	public var ship2 : Ship;
	
    public var planet : Planet;
    public var worldAABB : AABB;
    public var world : World;
    
    var nebula : Nebula;
	var hud : HUD;
	public var gameObjects : Sprite;
	
    var contactListener : ContactListener;
	
	public var scroll : Vector;
    var pbm : Bitmap;

    public function new(s1bm:Bitmap, s2bm:Bitmap, pbm:Bitmap) {
		super();
		this.pbm = pbm;
		scroll = Vector.init();
        contactListener = new ContactListener();
        contactListener.melee = this;
        timeStep = 1.0 / 60.0;
		gameObjects = new Sprite();
        initWorld();
        human = new Human(ship1, this);
		hud = new HUD(ship1, s1bm, ship2, s2bm);
		nebula = new Nebula(this);
		render = new RenderMelee(this);
		addChild(nebula);
		addChild(gameObjects);
		addChild(hud);
    }
	
	public function init() {
		stage.addEventListener(Event.ENTER_FRAME, loop);
		stage.addEventListener(Event.ENTER_FRAME, nebula.scroll);
		stage.addEventListener(Event.ENTER_FRAME, hud.update);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, human.onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, human.onKeyUp);
	}

   inline function loop(event:Event) {
	
		destroyList = new Set<Body>();
		
		// Update Physics
		world.step(timeStep, 10);
		// Update screen
		render.update();
		
        for (i in 0...gameObjects.numChildren) {
			var o = cast(gameObjects.getChildAt(i), ships.GameObject);
            if(o.checkDeath()) {
				continue;
            }
            o.limitVelocity();
            o.updateState();
            o.applyGravity();
            o.updateAI();
        }
		
		for (b in destroyList) {
			gameObjects.removeChild(b.object);
			world.removeBody(b);
		}
    }

    private function initWorld() {
		
	    // Define world boundaries
        var left = 0;
        var top = 0;
        var right = 500;
        var bottom = 500;
		// Physaxe inverts top and bottom because of Flash?
	    worldAABB = new AABB(left, top, right, bottom);
        var bf = new SortedList();
		world = new World(worldAABB, bf);
        world.gravity = new Vector(0.0,0.0);
        world.contactListener = contactListener;
        world.useIslands = false;
		
		ship2 = new UrQuan(this);
		ship1 = new Orz(this);
		ship2.initAI(ship1);
        planet = new Planet(this, pbm);
		
        for(i in 0...NUM_ASTROIDS) {
            var asteroid = new Asteroid(this);
        }
	}
	
	public function handleContact(rb1:Body, rb2:Body) {

		var go1 = rb1.object;
		var go2 = rb2.object;
		
		if (go1.group == go2.group) {
			go1.collect(go2);
			go2.collect(go1);
			return;
		}
		
		go1.applyDamage(go2.damage);
		go2.applyDamage(go1.damage);
    }
}
