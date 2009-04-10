/*
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
package melee;

import haxe.FastList;

import phx.col.AABB;
import phx.col.SortedList;
import phx.World;
import phx.WorldBoundaryListener;
import phx.Body;
import phx.Vector;

import ships.Ship;
import ships.GameObject;
import ships.UrQuan;
import ships.Orz;
import ships.Planet;
import ships.Asteroid;

import ai.AI;
import ai.Human;
import render.Render;

class Melee 
{
    static var NUM_ASTROIDS : Int = 12;
    public var objectList : FastList<GameObject>;
    var timeStep : Float;
    var allowSleep : Bool;
    var render : Render;

    var ai : AI;
    public var human : Human;

    public var ship1 : Ship;
	public var ship2 : Ship;
    var planet : Planet;

    var running : Bool;

    var worldAABB : AABB;
    public var world : World;
    
    public function new() {
                
        timeStep = 1.0/60.0;
        objectList = new FastList();
        
        initWorld();
        running = true;

        human = new Human(ship1, this);
        ai = new AI(ship2, objectList);
        render = new Render(this);
        
        objectList.add(planet);
        objectList.add(ship1);
        objectList.add(ship2);
    }

    public function run() {
        
        // Main game loop
        var i = 0;
        while (running && !human.quit && Render.running) {

            // Update Physics
            world.step(timeStep, 10);
            // Update screen
            render.update();
			
            for(o in objectList) {
                o.updateState();
                o.applyGravity();
            }
			
			// Update AI
            ai.move(ship1);
			
            // Apply thrust
            if(human.thrust) {
                ship1.thrust();
            }
        }
        render.close();
    }

    private function initWorld() {
	    // Define world boundaries
        var left = -400;
        var top = -250;
        var right = 400;
        var bottom = 250;
	    worldAABB = new AABB(left, top, right, bottom);
        var bf = new SortedList();
		world = new World(worldAABB, bf);
        world.gravity = new Vector(0.0,0.0);
        //world.useIslands = false;
		ship2 = new UrQuan(world);
		ship1 = new Orz(world);
        planet = new Planet(world);
        for(i in 0...NUM_ASTROIDS) {
            var asteroid = new Asteroid(world);
            objectList.add(asteroid);
        }
	}
}
