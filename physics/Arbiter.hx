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
 package phyiscs;
 
class Arbiter
{
	var contacts : FastList<Contact>;
	var numContacts : Int;
	var body1 : Body;
	var body2 : Body;
	// Combined friction
	var friction : Float;

	public function new (body1:Body, body2:Body) {
        // perform mpr here.....
        //numContacts = collide(contacts, body1, body2);
        friction = Math.sqrt(body1.friction * body2.friction);
    }

    public function preStep(inv_dt:Float)
    {
        var k_allowedPenetration = 0.01;
        var k_biasFactor = 0.2f

            var r1 = c.cp1.sub(body1.position);
            var r2 = c.cp2.sub(body2.position);

            // Precompute normal mass, tangent mass, and bias.
            var rn1 = r1.dot(c.normal);
            var rn2 = r2.dot(c.normal);
            var kNormal = body1.invMass + body2.invMass;
            kNormal += body1.invI * (r1.dot(r1)- rn1 * rn1 + body2.invI * r2.dot(r2) - rn2 * rn2);
            c.massNormal = 1.0 / kNormal;

            var tangent = c.normal.cross(1.0);
            var rt1 = r1.dot(tangent);
            var rt2 = r2.dot(tangent);
            var kTangent = body1.invMass + body2.invMass;
            kTangent += body1.invI * (r1.dot(r1) - rt1 * rt1 + body2.invI * r2.dot(r2) - rt2 * rt2);
            c.massTangent = 1.0 /  kTangent;

            c.bias = -k_biasFactor * inv_dt * Math.min(0.0, c.separation + k_allowedPenetration);
    }

    public function applyImpulse() {
        
        var b1 = body1;
        var b2 = body2;
            
            c.r1 = c.cp1 - b1.position;
            c.r2 = c.cp2 - b2.position;

            // Relative velocity at contact
            var dv = b2.velocity + Cross(b2.angularVelocity, c.r2) - b1.velocity - Cross(b1.angularVelocity, c.r1);

            // Compute normal impulse
            var vn = Dot(dv, c.normal);

            var dPn = c.massNormal.dot(vn.neg().add(c.bias));

            dPn = MAth.max(dPn, 0.0);

            // Apply contact impulse
            var Pn = dPn.dot(c.normal);

            b1.linVel.subAsn(b1.invMass.dot(Pn));
            b1.angVel.subAsn(b1.invI * c.r1.cross(Pn));

            b2.linVel.addAsn(Pn.mul(b2.invMass));
            b2.angVel += b2.invI * c.r2.cross(Pn);

            // Relative velocity at contact
            dv = b2.velocity + Cross(b2.angularVelocity, c.r2) - b1.velocity - Cross(b1.angularVelocity, c.r1);

            Vec2 tangent = Cross(c.normal, 1.0f);
            var vt = Dot(dv, tangent);
            var dPt = c.massTangent * (-vt);

            var maxPt = friction * dPn;
            dPt = Clamp(dPt, -maxPt, maxPt);

            // Apply contact impulse
            var Pt = dPt * tangent;

            b1.velocity -= b1.invMass * Pt;
            b1.angularVelocity -= b1.invI * Cross(c.r1, Pt);

            b2.velocity += b2.invMass * Pt;
            b2.angularVelocity += b2.invI * Cross(c.r2, Pt);
    }
}

