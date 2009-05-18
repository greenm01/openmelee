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
package render;

import utils.Util;

class Color
{

	public function new(rr:Float, gg:Float, bb:Float) {
		m_r = Std.int(255 * Util.clamp(rr, 0.0, 1.0));
		m_g = Std.int(255 * Util.clamp(gg, 0.0, 1.0));
		m_b = Std.int(255 * Util.clamp(bb, 0.0, 1.0));
	}
	
	public function set(rr:Float, gg:Float, bb:Float) {
		m_r = Std.int(255 * Util.clamp(rr, 0.0, 1.0));
		m_g = Std.int(255 * Util.clamp(gg, 0.0, 1.0));
		m_b = Std.int(255 * Util.clamp(bb, 0.0, 1.0));
	}
	
	public function setR(rr:Float) {
		m_r = Std.int(255 * Util.clamp(rr, 0.0, 1.0));
	}

	public function setG(gg:Float) {
		m_g = Std.int(255 * Util.clamp(gg, 0.0, 1.0));
	}

	public function setB(bb:Float) {
		m_b = Std.int(255 * Util.clamp(bb, 0.0, 1.0));
	}
	
	// Color
	public function getColor() {
		return (m_r << 16) | (m_g << 8) | (m_b);
	}
	
	var m_r : Int;
	var m_g : Int;
	var m_b : Int;

}
