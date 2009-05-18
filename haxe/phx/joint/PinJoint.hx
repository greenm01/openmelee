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

class PinJoint extends Joint {

	public var dist:Float;
	public var jnAcc:Float;
	public var jBias:Float;
	public var bias:Float;

	public function new(a:Body , b:Body , anchr1:Vector, anchr2:Vector) {
		
		jnAcc = jBias = bias = 0;
		var anchr1 = anchr1.clone();
		var anchr2 = anchr2.clone();
		super(a, b, anchr1, anchr2);
		var p1:Vector = new Vector(anchr1.x * a.rcos - anchr1.y * a.rsin, anchr1.x * a.rsin + anchr1.y * a.rcos);
		var p2:Vector = new Vector(anchr2.x * b.rcos - anchr2.y * b.rsin, anchr2.x * b.rsin + anchr2.y * b.rcos);

		p1.x += a.x;
		p1.y += a.y;
		p2.x += b.x;
		p2.y += b.y;

		dist = p2.minus(p1).length();
	}

	public override function preStep(dt_inv:Float ) {
		
		var a = b1;
		var b = b2;
		
		r1.x = anchr1.x * a.rcos - anchr1.y * a.rsin;
		r1.y = anchr1.x * a.rsin + anchr1.y * a.rcos;
		r2.x = anchr2.x * b.rcos - anchr2.y * b.rsin;
		r2.y = anchr2.x * b.rsin + anchr2.y * b.rcos;

		var p1 = new Vector(a.x, a.y);
		var p2 = new Vector(b.x, b.y);
		var dX:Float = (p2.x + r2.x) - (p1.x + r1.x);
		var dY:Float = (p2.y + r2.y) - (p1.y + r1.y);

		var ldist:Float = Math.sqrt(dX * dX + dY * dY);

		var nzldist:Float = (ldist == 0 ) ? phx.Const.FMAX : ldist;

		n.x = dX * (1 / nzldist);
		n.y = dY * (1 / nzldist);

		var mass_sum:Float = a.invMass + b.invMass;
		var r1cn:Float = r1.x * n.y - r1.y * n.x;
		var r2cn:Float = r2.x * n.y - r2.y * n.x;
		nMass = 1 / ( mass_sum + (a.invInertia * r1cn * r1cn) + (b.invInertia * r2cn * r2cn));

		bias = -joint_bias_coef * dt_inv * (ldist - dist);
		jBias = 0;

		var jx:Float = (n.x * jnAcc);
		var jy:Float = (n.y * jnAcc);

		//INLINE Function
		a.v.x += (-jx * a.invMass);
		a.v.y += (-jy * a.invMass);
		a.w += a.invInertia * (r1.x * -jy - r1.y * -jx);

		//INLINE Function
		b.v.x += (jx * b.invMass);
		b.v.y += (jy * b.invMass);
		b.w += b.invInertia * (r2.x * jy - r2.y * jx);
	}

	public override function applyImpuse() {

		var a = b1;
		var b = b2;
		
		var vbrX:Float = (b.v_bias.x + ( -r2.y * b.w_bias)) - (a.v_bias.x + ( -r1.y * a.w_bias));
		var vbrY:Float = (b.v_bias.y + ( r2.x * b.w_bias)) - (a.v_bias.y + ( r1.x * a.w_bias));

		var vbn:Float = vbrX * n.x + vbrY * n.y;

		var jbn:Float = (bias - vbn) * nMass;
		var jbnOld:Float = jBias;
		jBias = jbnOld + jbn;
		if (jBias > 0) jBias = 0;
		jbn = jBias - jbnOld;

		var jbx:Float = (n.x * jbn);
		var jby:Float = (n.y * jbn);

		//INLINE Function
		a.v_bias.x += (-jbx * a.invMass);
		a.v_bias.y += (-jby * a.invMass);
		a.w_bias   += a.invInertia * (r1.x * -jby - r1.y * -jbx);

		//INLINE Function
		b.v_bias.x += (jbx * b.invMass);
		b.v_bias.y += (jby * b.invMass);
		b.w_bias   += b.invInertia * (r2.x * jby - r2.y * jbx);

		var vrX:Float = (b.v.x + ( -r2.y * b.w)) - (a.v.x + ( -r1.y * a.w));
		var vrY:Float = (b.v.y + ( r2.x * b.w)) - (a.v.y + ( r1.x * a.w));

		var vrn:Float = vrX * n.x + vrY * n.y;

		var jn:Float = -vrn * nMass;

		jnAcc += jn;

		var jx:Float = (n.x * jn);
		var jy:Float = (n.y * jn);

		//INLINE Function
		a.v.x += (-jx * a.invMass);
		a.v.y += (-jy * a.invMass);
		a.w += a.invInertia * (r1.x * -jy - r1.y * -jx);

		//INLINE Function
		b.v.x += (jx * b.invMass);
		b.v.y += (jy * b.invMass);
		b.w += b.invInertia * (r2.x * jy - r2.y * jx);

	}

	public function draw( g:Graphics , drawBB:Bool ) {

		g.lineStyle(2, 0x333333);
		g.moveTo(b1.x + r1.x , b1.y + r1.y);
		g.lineTo(b2.x + r2.x , b2.y + r2.y);

	}

}

