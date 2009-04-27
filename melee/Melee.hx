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

class Melee extends Sprite
{
    static var NUM_ASTROIDS : Int = 3;
    public var objectList : FastList<GameObject>;
    var timeStep : Float;
    var allowSleep : Bool;
    public var render : RenderMelee;

    public var human : Human;
    public var ship1 : Ship;
	public var ship2 : Ship;
	
    public var planet : Planet;

    var running : Bool;

    var worldAABB : AABB;
    public var world : World;
    
    var contactListener : ContactListener;
    
    public function init() {
		
        contactListener = new ContactListener();
        contactListener.melee = this;
        
        timeStep = 1.0/60.0;
        objectList = new FastList<GameObject>();
        
        initWorld();
        running = true;

        human = new Human(ship1, this);
        
        objectList.add(planet);
        objectList.add(ship1);
        objectList.add(ship2);
		
        render = new RenderMelee(this);
    }

     // Main game loop
    public function loop() {
   
        for(o in objectList) {
            if(o.checkDeath()) {
                world.removeBody(o.rBody);
                objectList.remove(o);
                continue;
            }
            o.limitVelocity();
            o.updateState();
            o.applyGravity();
            o.updateAI();
        }
		
        // Update Physics
        world.step(timeStep, 20);
        // Update screen
        render.update();

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
        planet = new Planet(this);
		
        for(i in 0...NUM_ASTROIDS) {
            var asteroid = new Asteroid(this);
            objectList.add(asteroid);
        }
	}
	
	public function handleContact(rb1:Body, rb2:Body) {
	    var go1,go2 : GameObject;
	    go1 = go2 = null;
	    // Find the associated game object
	    for(o in objectList) {
	        if(o.rBody == rb1) {
	            go1 = o;
            } else if(o.rBody == rb2) {
                go2 = o;
            }
        }
        
		if(go1 == null || go2 == null) {
            return;
        }
		
		if (go1.group == go2.group) {
			go1.collect(go2);
			go2.collect(go1);
			return;
		}
		
		var damage1 = go1.damage;
		var damage2 = go2.damage;
		
		if (go1.applyDamage(damage2)) {
			objectList.remove(go1);
			go1 = null;
		}
		
		if (go2.applyDamage(damage1)) {
			objectList.remove(go2);
			go2 = null;
		}	    
    }
}
