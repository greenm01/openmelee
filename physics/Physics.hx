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

class Physics
{

    var space : Space;
    public function new(space:Space) {
        this.space = space;
    }
    
    public function solve() {
        
        // Integrate velocities and apply damping.
        for (b in space.bodyList) {
          
            // Integrate velocities.
            b.linearVelocity = b.linearVelocity + step.dt * (gravity + b.invMass * b.force);
            b.angularVelocity = b.angularVelocity + step.dt * b.invI * b.torque;

            // Reset forces.
            b.force = bzVec2.zeroVect;
            b.torque = 0.0f;

            // Apply damping.
            // ODE: dv/dt + c * v = 0
            // Solution: v(t) = v0 * exp(-c * t)
            // Time step: v(t + dt) = v0 * exp(-c * (t + dt)) = v0 * exp(-c * t) * exp(-c * dt) = v * exp(-c * dt)
            // v2 = exp(-c * dt) * v1
            // Taylor expansion:
            // v2 = (1.0f - c * dt) * v1
            b.linearVelocity = b.linearVelocity * bzClamp(1.0f - step.dt * b.linearDamping, 0.0f, 1.0f);
            b.angularVelocity = b.angularVelocity * bzClamp(1.0f - step.dt * b.angularDamping, 0.0f, 1.0f);

            // Check for large velocities.
            if (bzDot(b.linearVelocity, b.linearVelocity) > k_maxLinearVelocitySquared) {
                b.linearVelocity.normalize();
                b.linearVelocity *= k_maxLinearVelocity;
            }
            if (b.angularVelocity * b.angularVelocity > k_maxAngularVelocitySquared) {
                if (b.angularVelocity < 0.0f) {
                    b.angularVelocity = -k_maxAngularVelocity;
                } else {
                    b.angularVelocity = k_maxAngularVelocity;
                }
            }
        }
    }
}


















}
