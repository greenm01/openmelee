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
package org.openmelee.ai

import objects.ships.Ship

class Human (ship : Ship)
{

    var quit  = false;
    var turn = false;
  
	def onKeyDown(key:Int) {
        key match {
            case 1 => quit = true; // ESC
            case 17 => ship.engines = true; // 'w' (thrust)
            case 30 => // 'a' (left)
                if (!ship.turnL) {
					if(!ship.special) 
						ship.turnLeft()
                    ship.turnL = true;
                }
            case 32 => // 'd' (right)
                if (!ship.turnR) {
					if(!ship.special)
						ship.turnRight()
                    ship.turnR = true
				}
            case 52 => ship.primary = true; // '.' (fire)
			case 53 => ship.special = true;// '/' (special)
			case _ => 
		}
    }

    def onKeyUp(key:Int) {
        if (key == 30 || key == 32) {
            ship.turnR = false
            ship.turnL = false
            ship.body.angularVelocity = 0
        } else if(key == 17) {
            ship.engines = false
        } else if (key == 53) {
			ship.special = false
		} else if (key == 52) {
			ship.primary = false
		}
	}
}