/*
 * Copyright (c) 2009, Mason Green (zzzzrrr)
 * http://kenai.com/projects/haxmel
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
package haxmel.melee.melee;

import blaze.common.bzMath : bzVec2;
import blaze.bzWorld : bzWorld;
import blaze.collision.bzCollision : bzAABB;
import blaze.collision.shapes.bzShape : bzShape;
import blaze.dynamics.bzBody : bzBody;
import blaze.dynamics.contact.bzContact : bzContactPoint;
import blaze.collision.bzCollision : bzContactID;

import openmelee.melee.boundaryListener : BoundaryListener;
import openmelee.melee.contactListener : ContactListener;
import openmelee.render.render;
import openmelee.ai.ai : AI;
import openmelee.ai.human : Human;
import openmelee.ships.ship : Ship;
import openmelee.ships.urQuan : UrQuan;
import openmelee.ships.orz : Orz;
import openmelee.ships.planet : Planet;
import openmelee.ships.asteroids : Asteroid;

var k_maxContactPoints = 100;
var NUM_ASTROIDS = 12;

alias LinkedList!(Ship) ObjectList;

// World settings
typedef Settings {
    hz : Float = 60;
    velocityIterations : Int = 3;
    positionIterations : Int = 1;
    enableWarmStarting : Bool;
    enableTOI : Bool;
}

typedef ContactPoint {
    shape1 : Shape;
    shape2 : Shape;
    normal : Vec2;
    position : Vec2;
    velocity : Vec2;
}

class Melee {

    var objectList : FastList<Ship>;
    var settings : Settings;
    var timeStep : Float;
    var gravity : Vec2;
    var allowSleep : Bool;
    var render : Render;

    var ai : AI;
    var human : Human;

    var ship1 : Ship;
	var ship2 : Ship;
    var planet : Ship;

    var running : Bool;

    var worldAABB : AABB;
    var world : World;
    var pointCount : Int;

    public function new() {
        
        timeStep = settings.hz > 0.0f ? 1.0f / settings.hz : 0.0f;
        gravity = new Vec2(0, 0);
        objectList = new ObjectList;
		m_boundaryListener = new BoundaryListener(this);


        initWorld();
        running = true;

        human = new Human(ship1, this);
        ai = new AI(ship2, objectList);

        render = new Render(world, ship1, ship2, human, settings);

        objectList.add(planet);
        objectList.add(ship1);
        objectList.add(ship2);
    }

    public function run() {
        
        // Main game loop
        while (running && !human.quit && render.running) {

            float delta = timer.stop;
            timer.start;

            // Update AI
            ai.move(ship1);
            // Update Physics
            world.step(timeStep, settings.velocityIterations, settings.positionIterations);
            // Update screen
            render.update();

            // Limit velocities
            for(o in objectList) {
                o.limitVelocity();
                o.updateState();
            }

            // Apply thrust
            if(human.thrust && ship1) {
                ship1.thrust();
            }
        }
    }

    private function initWorld() {
	    // Define world boundaries
		worldAABB.lowerBound.set(-400.0f, -250.0f);
		worldAABB.upperBound.set(400.0f, 250.0f);
		world = new World(worldAABB, gravity, allowSleep);
		world.boundaryListener = m_boundaryListener;
		ship2 = new UrQuan(world);
		ship1 = new Orz(world);
        ship2.rBody.angle = 3.14159265/4;
        planet = new Planet(world);
        for(int i; i < NUM_ASTROIDS; i++) {
            auto asteroid = new Asteroid(world);
            objectList.add(asteroid);
        }
	}

    private function boundaryViolated(Body rb)
	{
        if(rb.position.x > worldAABB.upperBound.x) {
            rb.x = worldAABB.lowerBound.x + 5;
        } else if (rBody.position.x < worldAABB.lowerBound.x) {
            rb.x = worldAABB.upperBound.x - 5;
        } else if (rBody.position.y > worldAABB.upperBound.y) {
            rb.y = worldAABB.lowerBound.y + 5;
        } else if(rBody.position.y < worldAABB.lowerBound.y) {
            rb.y = worldAABB.upperBound.y - 5;
        }
	}
}
