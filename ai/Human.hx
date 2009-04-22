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
package ai;

import ships.Ship;
import ships.UrQuan;
import melee.Melee;

class Human
{
    var melee : Melee;
    var ship : Ship;
    public var quit : Bool;
    var turn : Bool;
    
	public function new(ship : Ship, melee : Melee) {
        this.melee = melee;
        this.ship = ship;
	}

	public function onKeyDown(key:Int) {
        switch (key) {
            case 29: // ESC
                quit = true;
            case 87: // 'w' (thrust)
                ship.engines = true;
            case 65: // 'a' (left)
                if (!ship.turnL) {
					if(!ship.special) {
						ship.turnLeft();
					}
                    ship.turnL = true;
                }
            case 68: // 'd' (right)
                if (!ship.turnR) {
					if(!ship.special) 
						ship.turnRight();
					}
                    ship.turnR = true;
            case 40: // DOWN
            case 190: // '.' (fire)
				ship.primary = true;
			case 191: // '/' (special)
				ship.special = true;
		}
    }
    
    public function onKeyUp(key:Int) {
        if (key == 65 || key == 68) {
            ship.turnR = false;
            ship.turnL = false;
            ship.rBody.w = 0.0;
        } else if(key == 87) {
            ship.engines = false;
        } else if (key == 191) {
			ship.special = false;
		} else if (key == 190) {
			ship.primary = false;
		}
	}
}
