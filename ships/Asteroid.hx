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
package ships;

import phx.World;
import phx.Vector;
import phx.Circle;
import phx.Body;

import melee.Melee;
import utils.Util;

class Asteroid extends GameObject
{
    
    public function new(melee:Melee) {
        super(melee);
        var radius = 1.0;
		var offset = new Vector(-1.0, 1.0);
		var s1 = new Circle(radius, offset);
		
		offset.set(1.0,1.0);
		var s2 = new Circle(radius, offset);
		
		var x = Util.randomRange(-100.0, 100.0);
		var y = Util.randomRange(-100.0, 100.0);
		var angle = Util.randomRange(-Math.PI, Math.PI);
		rBody = new Body(x,y, props);
		rBody.v.x = x;
		rBody.v.y = y;
		rBody.a = angle;
		rBody.addShape(s1);
		rBody.addShape(s2);
		
		world.addBody(rBody);
		draw(0xFF0000);
		init();
    }

}
