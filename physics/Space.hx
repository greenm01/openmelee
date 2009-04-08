/*
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
package physics;

import haxe.FastList;

class Space 
{
    public var spaceAABB : AABB;
    var m_broadPhase : BroadPhase;
    var m_mpr : Mpr;
    public var bodyList : FastList<Body>;
    public var contactList : FastList<Contact>;
    var physics : Physics;
    
    public function new(spaceAABB:AABB) {
        
        this.spaceAABB = spaceAABB;
        m_broadPhase = new HGrid(bodyList);
        m_mpr = new Mpr();
        bodyList = new FastList();
	contactList = new FastList();
        physics = new Physics(this);
    }
    
    public inline function step(dt:Float) {

        //var inv_dt = if(dt > 0.0) 1.0 / dt else 0.0;
        
        // Determine overlapping bodies and update contact points.
        //updateBroadphase();
        
        
        // Integrate forces.
        for (b in bodyList) {
            if (b.invMass == 0.0) continue;
            b.linVel.addAsn(b.force.mul(b.invMass*dt));
            b.angVel += dt * b.invI * b.torque;
        }

        /*
        // Perform pre-steps.
        for (arb in arbiterList)
        {
            arb.preStep(inv_dt);
        }

        // Perform iterations
        for (i in 0...iterations) {
            for (arb in arbiterList)
            {
                arb.applyImpulse();
            }
        }
        */
        updateNarrowphase();
        
        // Integrate Velocities
        for (b in bodyList) {
            b.pos.addAsn(b.linVel.mul(dt));
            b.angle += dt * b.angVel;
            b.synchronizeTransform();
            b.synchronizeShapes();
            b.force.set(0.0, 0.0);
            b.torque = 0.0;
        }
    }
    
    public inline function updateBroadphase(){
        m_broadPhase.update();
        m_broadPhase.commit();
    }
    
    public inline function updateNarrowphase() {
	for(i in bodyList) {
	    for(j in bodyList) {
		if(i == j) continue;
		   for(ic in i.shapeList) {
			for(jc in j.shapeList) {
				var contact = new Contact(ic, jc);
				if(m_mpr.collide(contact)) {
					physics.test(contact);
				}
			}
		}
	    }
        }
    }
    
    public function addBody(body:Body) {
        bodyList.add(body);
    }
    
    public function removeBody(body:Body) {
        bodyList.remove(body);
    }
    
    public function addJoint() {
    }
    
    public function removeJoint() {
    }
}
