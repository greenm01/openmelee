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
package physics;

import utils.Vec2;

class Physics
{

    var space : Space;
    var gravity : Vec2;
    
    var k_maxLinearVelocity : Float;
    var k_maxLinearVelocitySquared : Float;
    var k_maxAngularVelocity : Float;
    var k_maxAngularVelocitySquared : Float;
    
    // Coefficient of restitution
    var fCr : Float; 		
    
    public function new(space:Space) {
        
        gravity = new Vec2(0.0,0.0);
        this.space = space;
        
        k_maxAngularVelocity = 250.0;
        k_maxLinearVelocity = 200.0;
        k_maxLinearVelocitySquared = k_maxLinearVelocity * k_maxLinearVelocity;
        k_maxAngularVelocitySquared = k_maxAngularVelocity * k_maxAngularVelocity;
        
        fCr = 1.0;
    }
    
    public function solve(dt:Float) {
        
        // Integrate velocities and apply damping.
        for (b in space.bodyList) {
          
            // Integrate velocities.
            b.linVel.addAsn(gravity.add(b.force.mul(b.invMass)).mul(dt));
            b.angVel *= (b.torque * b.invI * dt);

            // Reset forces.
            b.force.set(0.0, 0.0);
            b.torque = 0.0;

            // Apply damping.
            // ODE: dv/dt + c * v = 0
            // Solution: v(t) = v0 * exp(-c * t)
            // Time step: v(t + dt) = v0 * exp(-c * (t + dt)) = v0 * exp(-c * t) * exp(-c * dt) = v * exp(-c * dt)
            // v2 = exp(-c * dt) * v1
            // Taylor expansion:
            // v2 = (1.0f - c * dt) * v1
            b.linVel.mulAsn(Vec2.clamp(1.0 - dt * b.linearDamping, 0.0, 1.0));
            b.angVel *= Vec2.clamp(1.0 - dt * b.angularDamping, 0.0, 1.0);

            // Check for large velocities.
            if (b.linVel.dot(b.linVel) > k_maxLinearVelocitySquared) {
                b.linVel.normalize();
                b.linVel.mulAsn(k_maxLinearVelocity);
            }
            if (b.angVel * b.angVel > k_maxAngularVelocitySquared) {
                if (b.angVel < 0.0) {
                    b.angVel = -k_maxAngularVelocity;
                } else {
                    b.angVel = k_maxAngularVelocity;
                }
            }
            
            // Update positions
            b.pos.addAsn(b.linVel.mul(dt));
            b.angle = b.angle + b.angVel*dt;
        }
    }
    
    public function applyImpulse(rb1:Body, rb2:Body, cp1:Vec2, cp2:Vec2, normal:Vec2) {
        
        var rA = cp1.sub(rb1.pos.add(rb1.localCenter));
        var rB = cp2.sub(rb2.pos.add(rb2.localCenter));
        var rVel = rb1.linVel.sub(rb2.linVel);
        var kA = rA.cross(normal);
        var kB = rB.cross(normal);
        var uA = kA * rb1.invI;
        var uB = kB * rb2.invI;
        var fNumer = (-(1+fCr)) * normal.dot(rVel) + (rb1.angVel*kA - rb2.angVel*kA);
        var fDenom = rb1.invMass + rb2.invMass + kA * uA + kB * uB;
        var f = fNumer/fDenom;
        var impulse = normal.mul(f);
        
        rb1.linVel.addAsn(impulse.mul(rb1.invMass));
        rb1.angVel += rb1.invI * cp1.sub(rb1.localCenter).cross(impulse);
        
        impulse = impulse.neg();
        rb2.linVel.addAsn(impulse.mul(rb2.invMass));
        rb2.angVel += rb2.invI * cp2.sub(rb2.localCenter).cross(impulse);

    }


}
