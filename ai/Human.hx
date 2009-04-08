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
package ai;

import opengl.GLFW;

import ships.Ship;
import melee.Melee;

class Human
{
    var melee : Melee;
    var ship : Ship;
    public var quit : Bool;
    public var thrust : Bool;

	public function new(ship : Ship, melee : Melee) {
        this.melee = melee;
        this.ship = ship;
	}

	public function onKey(key : Int, state : Int) {
        // Key pressed
		if (state == GLFW.PRESS) {
			switch (key) {
			case GLFW.KEY_ESC:
                quit = true;
            case GLFW.KEY_UP:
                thrust = true;
            case GLFW.KEY_LEFT:
                ship.turnLeft();
            case GLFW.KEY_RIGHT:
                ship.turnRight();
                trace(ship.rBody.torque);
            case GLFW.KEY_DOWN:
            case GLFW.KEY_DEL:
                melee.ship2.explode();
                melee.objectList.remove(melee.ship2);
                melee.space.removeBody(melee.ship2.rBody);
                melee.ship2 = null;
			}
        // Key released
		} else {
		    if(key == GLFW.KEY_UP) {
		         thrust = false;
		    } else if (key == GLFW.KEY_LEFT || key == GLFW.KEY_RIGHT) {
                ship.rBody.angVel = 0.0;
            }
		}
	}
}
