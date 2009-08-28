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

import flash.display.Bitmap;
import flash.display.BitmapData;

import phx.Body;
import phx.World;
import phx.Circle;
import phx.Vector;

import melee.Melee;

class Planet extends GameObject
{
   
	public var pbm : Bitmap;

    public function new(melee:Melee, pbm:Bitmap) {
        super(melee);
		this.pbm = pbm;
        // Create planet
        group = -1;
		damage = 3;
        var radius = 7.0;
        var offset = Vector.init();
        var planet = new Circle(radius, offset);
		rBody = new Body(400, 250);
		rBody.addShape(planet);
		rBody.isStatic = true;
        world.addBody(rBody);
        
        state.pos.x = 400.0;
        state.pos.y = 250.0;
        calcRadius();
		//draw(0x0022aa);
		init();
		addChild(pbm);
		pbm.scaleX = pbm.scaleY = 0.059;
		pbm.x = -8.6;
		pbm.y = -8.5;
    }
}
