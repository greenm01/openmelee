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
    var friction : Float;
    
    var k_maxLinearVelocity : Float;
    var k_maxLinearVelocitySquared : Float;
    var k_maxAngularVelocity : Float;
    var k_maxAngularVelocitySquared : Float;

    var k_allowedPenetration : Float; 
	var k_biasFactor : Float;
    
    // Coefficient of restitution
    var fCr : Float;

    public function new(space:Space) {

        gravity = new Vec2(0.0,0.0);
        this.space = space;
        friction = 0.5;
        
        k_maxAngularVelocity = 2.0;
        k_maxLinearVelocity = 25.0;
        k_maxLinearVelocitySquared = k_maxLinearVelocity * k_maxLinearVelocity;
        k_maxAngularVelocitySquared = k_maxAngularVelocity * k_maxAngularVelocity;

        k_allowedPenetration =0.01;
        k_biasFactor = 0.2;
        
        fCr = 1.0;
    }

    public function solve(dt:Float) {

        // Integrate velocities and apply damping.
        for (b in space.bodyList) {

            // Integrate velocities.
            b.linVel.addAsn(gravity.add(b.force.mul(b.invMass)).mul(dt));
            b.angVel += (b.torque * b.invI * dt);

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
        }
    }

    public function applyImpulse(contact:Contact) {

        var rb1 = contact.shape1.body;
        var rb2 = contact.shape2.body;
        var cp1 = contact.cp1;
        var cp2 = contact.cp2;
        var normal = contact.normal;

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
    
    public function test(c:Contact) {
        
        var inv_dt = (1.0/60.0)/60.0;
        
        var b1 = c.shape1.body;
        var b2 = c.shape2.body;
        
        c.cp1 = b1.pos.sub(c.cp1);
        c.cp2 = b2.pos.sub(c.cp2);
        
        var r1 = c.cp1.sub(b1.pos);
        var r2 = c.cp2.sub(b2.pos);

        // Precompute normal mass, tangent mass, and bias.
        var rn1 = r1.dot(c.normal);
        var rn2 = r2.dot(c.normal);
        var kNormal = b1.invMass + b2.invMass;
        kNormal += b1.invI * (r1.dot(r1)- rn1 * rn1 + b1.invI * r2.dot(r2) - rn2 * rn2);
        c.massNormal = 1.0 / kNormal;

        var tangent = cross(1.0, c.normal);
        var rt1 = r1.dot(tangent);
        var rt2 = r2.dot(tangent);
        var kTangent = b1.invMass + b2.invMass;
        kTangent += b1.invI * (r1.dot(r1) - rt1 * rt1 + b2.invI * r2.dot(r2) - rt2 * rt2);
        c.massTangent = 1.0 /  kTangent;

        c.bias = -k_biasFactor * inv_dt * Math.min(0.0, c.separation + k_allowedPenetration);
        
        c.r1 = c.cp1.sub(b1.pos);
        c.r2 = c.cp2.sub(b2.pos);

        // Relative velocity at contact
        var dv = b2.linVel.add(cross(b2.angVel, c.r2)).sub(b1.linVel).sub(cross(b1.angVel, c.r1));
        
        trace(dv.x + "," + dv.y);
        
        // Compute normal impulse
        var vn = dv.dot(c.normal);

        var dPn = c.massNormal * (-vn + c.bias);

        dPn = Math.max(dPn, 0.0);

        // Apply contact impulse
        var Pn = c.normal.mul(dPn);

        b1.linVel.subAsn(Pn.mul(b1.invMass));
        b1.angVel -= b1.invI * c.r1.cross(Pn);

        b2.linVel.addAsn(Pn.mul(b2.invMass));
        b2.angVel += b2.invI * c.r2.cross(Pn);

        // Relative velocity at contact
        dv = b2.linVel.add(cross(b2.angVel, c.r2)).sub(b1.linVel).sub(cross(b1.angVel, c.r1));

        var tangent = cross(1.0, c.normal);
        var vt = dv.dot(tangent);
        var dPt = c.massTangent * -vt;

        var maxPt = friction * dPn;
        dPt = Vec2.clamp(dPt, -maxPt, maxPt);

        // Apply contact impulse
        var Pt =  tangent.mul(dPt);

        b1.linVel.subAsn(Pt.mul(b1.invMass));
        b1.angVel -= b1.invI * c.r1.cross(Pt);

        b2.linVel.addAsn(Pt.mul(b2.invMass));
        b2.angVel += b2.invI * c.r2.cross(Pt);
            
    }
    
    inline function cross(s:Float, a:Vec2) {
        return new Vec2(-s * a.y, s * a.x);
    }


}
