/*
 * Copyright (c) 2009, Mason Green 
 * http://github.com/zzzzrrr/haxmel
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

import physics.AABB;
import physics.Space;

import ships.Ship;
import ships.UrQuan;
import ships.Orz;
import ai.Human;
import render.Render;

//import ai.AI;

// World settings
typedef Settings = {
    var hz : Float;
    var iterations : Int;
}

class Melee 
{
    static var NUM_ASTROIDS : Int = 12;
    public var objectList : FastList<Ship>;
    var settings : Settings;
    var timeStep : Float;
    var gravity : Vec2;
    var allowSleep : Bool;
    var render : Render;

    //var ai : AI;
    public var human : Human;

    public var ship1 : Ship;
	public var ship2 : Ship;
    //svar planet : Ship;

    var running : Bool;

    var worldAABB : AABB;
    public var space : Space;

    public function new() {
        
        settings = {hz : 60.0, iterations : 2};
        timeStep = if(settings.hz > 0.0) 1.0 / settings.hz else 0.0;
    
        gravity = new Vec2(0, 0);
        objectList = new FastList();

        initWorld();
        running = true;

        human = new Human(ship1, this);
        //ai = new AI(ship2, objectList);
        render = new Render(this, settings);

        //objectList.add(planet);
        objectList.add(ship1);
        objectList.add(ship2);
    }

    public function run() {
        
        // Main game loop
        while (running && !human.quit && Render.running) {

            // Update AI
            //ai.move(ship1);
            // Update Physics
            space.step(timeStep, settings.iterations);
            // Update screen
            render.update();

            if(Math.isNaN(ship1.rBody.x)) {
                throw "bad";
            }
            
            // Limit velocities
            for(o in objectList) {
                //o.limitVelocity();
                //o.updateState();
            }

            // Apply thrust
            if(human.thrust) {
                ship1.thrust();
            }
        }
    }

    private function initWorld() {
	    // Define world boundaries
        var upperBound = new Vec2(400,250);
        var lowerBound = new Vec2(-400,-250);
	    worldAABB = new AABB(upperBound, lowerBound);
		world = new Space(worldAABB);
		world.gravity = new Vec2(0,-5);
		//ship2 = new UrQuan(world);
		ship1 = new Orz(world);
        //planet = new Planet(world);
        for(i in 0...NUM_ASTROIDS) {
            //var asteroid = new Asteroid(world);
            //objectList.add(asteroid);
        }
	}

    private function boundaryViolated(rb : Body)
	{
        if(rb.pos.x > worldAABB.r) {
            rb.pos.x = worldAABB.l + 5;
        } else if (rb.x < worldAABB.l) {
            rb.pos.x = worldAABB.r - 5;
        } else if (rb.y > worldAABB.t) {
            rb.pos.y = worldAABB.b + 5;
        } else if(rb.y < worldAABB.b) {
            rb.pos.y = worldAABB.t - 5;
        }
	}
}
