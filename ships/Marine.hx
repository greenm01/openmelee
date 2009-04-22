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

import flash.geom.Vector3D;
import phx.Vector;
import phx.Polygon;
import phx.Circle;
import phx.Body;

import melee.Melee;
import ai.AI;
import ai.Steer;

// Autonomous Space Marine - Ooh-rah!
class Marine extends Ship
{
	// Jarhead's mothership
	var motherShip : Orz;
	// The enemy to kill
	
	public function new(melee:Melee, motherShip:Orz) {
		super(melee);
		this.motherShip = motherShip;
		crew = 5.0;
		lifetime = 45.0;
		var scale = 3.0;
		props.maxMotion = 5e3;
		
		/*
		var verts = new Array<Vector>();
		verts.push(new Vector(0.0,0.25*scale));
		verts.push(new Vector(0.15*scale,0.0));
		verts.push(new Vector( -0.15*scale, 0.0));
		var poly = new Polygon(verts, Vector.init());
		*/
		
		var offset = Vector.init();
		var poly = new Circle(scale * 0.15, offset);
		state.radius = scale * 0.15;
		
		var localPos = new Vector(0, 1.25);
		var worldPos = motherShip.turret.worldPoint(localPos);
		rBody = new Body(worldPos.x, worldPos.y, props);
		rBody.addShape(poly);
		rBody.v.set(-motherShip.rBody.v.x, -motherShip.rBody.v.x);
		world.addBody(rBody);
		
		engineForce = (new Vector(10, 0)).mult(rBody.mass);
        turnForce = (new Vector(0, 10)).mult(rBody.mass);
        rightTurnPoint = new Vector( -0.15*scale, 0);
		leftTurnPoint = new Vector(0.15 * scale, 0);
	}		
	
	public override function updateAI() {
		
		var time = flash.Lib.getTimer() / 1000;
		
		var threat : Threat = {target:null, steering:Vector.init(), distance:0.0, collisionTime:0.0, 
                                minSeparation:phx.Const.FMAX, relativePos:Vector.init(), relativeVel:Vector.init() }; 
								
		var steer = new Steer(this, melee.objectList);
		steer.update();
		
		var maxPredictionTime = 0.5;
		
		steer.collisionThreat(threat);
		var st : Vector = threat.steering;
		
		if ((st.x == 0.0 && st.y == 0.0) || threat.target == enemy) {
			if ((time-birthday) > 0.5 * lifetime) {
				// Return to motherShip
				enemy = motherShip;
			}
			st = steer.target(enemy.state, maxPredictionTime);
			state.target = st;
			//st = steer.steerForSeek(st);
			st = rBody.localPoint(st);
			st.normalize();
			st = st.mult(500.0);
			rBody.f.x += st.x * rBody.mass;
			rBody.f.y += st.y * rBody.mass;
		} else {
			st = threat.target.state.pos;
			st = rBody.localPoint(st);
			st.normalize();
			st = st.mult(-1000.00);
			rBody.f.x += st.x * rBody.mass;
			rBody.f.y += st.y * rBody.mass;
		}
	}
	
	public override function applyGravity() {
		
	}

}
