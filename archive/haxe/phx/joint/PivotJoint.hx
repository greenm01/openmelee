/* OpenMelee
 * Copyright (c) 2009, Mason Green 
 * http://github.com/zzzzrrr/openmelee
 * Ported from Glaze
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
package phx.joint;

import flash.display.Graphics;  

import phx.Vector;
import phx.Body;

class PivotJoint extends Joint {
		
	private var jAcc:Vector;
	private var jBias:Vector;
	private var bias:Vector;
	
	private var k1:Vector;
	private var k2:Vector;
	
	public function new(a:Body, b:Body, pivot:Vector ) {
			var anchr1 = pivot.minus(new Vector(a.x, a.y)).rotateByVector(new Vector(a.rcos, a.rsin));
			var anchr2 = pivot.minus(new Vector(b.x, b.y)).rotateByVector(new Vector(b.rcos, b.rsin));                
			super(a, b, anchr1, anchr2);
			jAcc   = Vector.init();
			jBias  = Vector.init();
			bias   = Vector.init();
	}

	public override function preStep( dt_inv:Float ) {
		
		var a = b1;
		var b = b2;
		
		r1 = anchr1.rotateByVector(new Vector(a.rcos, a.rsin));
		r2 = anchr2.rotateByVector(new Vector(b.rcos, b.rsin));

		// calculate mass matrix
		var k11:Float;
		var k12:Float;
		var k21:Float; 
		var k22:Float;

		var m_sum:Float = a.invMass + b.invMass;
		k11 = m_sum; 
		k12 = 0.0;
		k21 = 0.0;
		k22 = m_sum;

		var r1xsq:Float = r1.x * r1.x * a.invInertia;
		var r1ysq:Float = r1.y * r1.y * a.invInertia;
		var r1nxy:Float = -r1.x * r1.y * a.invInertia;
		k11 += r1ysq; k12 += r1nxy;
		k21 += r1nxy; k22 += r1xsq;

		var r2xsq:Float = r2.x * r2.x * b.invInertia;
		var r2ysq:Float = r2.y * r2.y * b.invInertia;
		var r2nxy:Float = -r2.x * r2.y * b.invInertia;
		k11 += r2ysq; k12 += r2nxy;
		k21 += r2nxy; k22 += r2xsq;

		var det_inv:Float = 1.0 / (k11 * k22 - k12 * k21);
		k1 = new Vector(k22 * det_inv, -k12 * det_inv);
		k2 = new Vector(-k21 * det_inv, k11 * det_inv);

		// calculate bias velocity
		var p1 = new Vector(a.x, a.y);
		var p2 = new Vector(b.x, b.y);
		var delta:Vector = p2.plus(r2).minus(p1.plus(r1));
		bias  = delta.mult(-joint_bias_coef * dt_inv);
		jBias = Vector.init();

		// apply accumulated impulse
		a.applyImpulse(jAcc.mult(-1), r1);
		b.applyImpulse(jAcc, r2);
	}

	public override function applyImpuse() {
		
		var a = b1;
		var b = b2;
		
		//calculate bias impulse
		var vb1:Vector = a.v_bias.plus(r1.rotateLeft90().mult(a.w_bias));
		var vb2:Vector = b.v_bias.plus(r2.rotateLeft90().mult(b.w_bias));
		var vbr:Vector = bias.minus(vb2.minus(vb1));

		var jb:Vector = new Vector(vbr.dot(k1), vbr.dot(k2));
		jBias = jBias.plus(jb);

		a.applyImpulse(jb.mult(-1), r1);
		b.applyImpulse(jb, r2);

		// compute relative velocity
		var v1:Vector = a.v.plus(r1.rotateLeft90().mult(a.w));
		var v2:Vector = b.v.plus(r2.rotateLeft90().mult(b.w));
		var vr:Vector = v2.minus(v1);

		// compute normal impulse
		var j:Vector = new Vector(-vr.dot(k1), -vr.dot(k2));
		jAcc = jAcc.plus(j);

		// apply impulse
		a.applyImpulse(j.mult(-1), r1);
		b.applyImpulse(j, r2);
	}
	
	public function draw(g:Graphics, drawBB:Bool ) {
		g.lineStyle(2, 0x333333);
		g.moveTo(b1.x , b1.y );
		g.lineTo(b2.x , b2.y );

	}
}

