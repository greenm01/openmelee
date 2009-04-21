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

import phx.Vector;
import phx.Polygon;
import phx.Body;

import melee.Melee;
import ai.AI;

// Autonomous Space Marine - Ooh-rah!
class Marine extends Ship
{
	// The ship this Jarhead deploys from
	var motherShip : Orz;
	// The enemy to kill
	
	public function new(melee:Melee, motherShip:Orz) {
		super(melee);
		props.maxMotion = 5e3;
		this.motherShip = motherShip;
		initAI(melee.ship2);
		engineForce = new Vector(0, 300);
        turnForce = new Vector(3000, 0);
        rightTurnPoint = new Vector( -0.15, 0);
		leftTurnPoint = new Vector(0.15, 0);
		
		var verts = new Array<Vector>();
		verts.push(new Vector(0.0,0.25));
		verts.push(new Vector(0.15,0.0));
		verts.push(new Vector( -0.15, 0.0));
		var poly = new Polygon(verts, Vector.init());
		var localPos = new Vector(0, 1.25);
		var worldPos = motherShip.turret.worldPoint(localPos);
		rBody = new Body(worldPos.x, worldPos.y, props);
		rBody.addShape(poly);
		world.addBody(rBody);
	}
	
	public override function applyGravity() {
	}
	
}
