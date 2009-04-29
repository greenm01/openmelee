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
import utils.Util;

// Autonomous Space Marine - Ooh-rah!
class Marine extends Ship
{
    // Jarhead's mothership
    var motherShip : Orz;
    // The enemy to kill
    var steer : Steer;
    
    public function new(melee:Melee, motherShip:Orz) {
        super(melee);
        maxLinVel = 12.0;
        maxAngVel = 0.0;
        group = motherShip.group;
        steer = new Steer(this, melee.objectList);
        this.motherShip = motherShip;
        crew = 5;
        lifetime = 60.0;
        var scale = 3.0;
        
        /*
        var verts = new Array<Vector>();
        verts.push(new Vector(0.0,0.25*scale));
        verts.push(new Vector(0.15*scale,0.0));
        verts.push(new Vector( -0.15*scale, 0.0));
        var poly = new Polygon(verts, Vector.init());
        */
        
        var offset = Vector.init();
        var poly = new Circle(scale * 0.15, offset);
        
        var localPos = new Vector(0, 1.25);
        var worldPos = motherShip.turret.worldPoint(localPos);
        rBody = new Body(worldPos.x, worldPos.y, props);
        rBody.v.x = -motherShip.rBody.v.x;
        rBody.v.y = -motherShip.rBody.v.y;
        rBody.addShape(poly);
        world.addBody(rBody);
        
        engineForce = (new Vector(10, 0)).mult(rBody.mass);
        turnForce = (new Vector(0, 10)).mult(rBody.mass);
        rightTurnPoint = new Vector( -0.15*scale, 0);
        leftTurnPoint = new Vector(0.15 * scale, 0);
        
        calcRadius();
        // Add some margin
        radius += 2.0;
    }        
    
    public override function updateAI() {

        if(enemy == null) return;
        
        var time = flash.Lib.getTimer() / 1000;
        var zeroVec = Vector.init();
        
        var threat : Threat = {target:null, steering:zeroVec, distance:0.0, collisionTime:0.0, 
                                minSeparation:phx.Const.FMAX, relativePos:zeroVec, relativeVel:zeroVec};
        steer.update();
        
        var maxPredictionTime = 0.05;
        var st = steer.collisionThreat(threat, 10.0);
    
        var range = (state.pos.minus(melee.planet.state.pos)).length(); 
        var margin = melee.planet.radius + radius;
        
        if ((st == null || threat.target == enemy) && range > margin) {
            if ((time-birthday) > 0.5 * lifetime || enemy.dead) {
                // Return to motherShip
                enemy = motherShip;
            }
            st = steer.target(enemy.state, maxPredictionTime);
            state.target = st;
            st = rBody.localPoint(st);
            st.normalize();
            st = st.mult(200.0);
            rBody.f.x += st.x;
            rBody.f.y += st.y;
        } else if(threat.target != null) {
            // compute avoidance steering force: take offset from obstacle to me,
            // take the component of that which is lateral (perpendicular to my
            // forward direction), set length to maxForce, add a bit of forward
            // component (we never want to slow down)
            var offset = state.pos.minus(threat.target.state.pos);
            var fwd = state.linVel.clone(); fwd.normalize();
            var avoidance = Util.perpendicularComponent(offset, fwd);
            avoidance.normalize();
            var maxForce = 200.0;
            avoidance = avoidance.mult(maxForce);
            avoidance.x += fwd.x * maxForce * 0.75;
            avoidance.y += fwd.y * maxForce * 0.75;
            
            // Make sure we apply force in correct direction
            if(offset.cross(avoidance) < 0.0) {
                avoidance = avoidance.rotateLeft90();
            }
            
            rBody.f.x += avoidance.x;
            rBody.f.y += avoidance.y;
        }
    }

    public override function uponDeath() {
        motherShip.numMarines--;
    }
    
    public override function applyGravity() {
        
    }

}
