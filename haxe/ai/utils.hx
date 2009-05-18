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
module openmelee.ai.utilities;
 
import tango.math.random.Kiss : Kiss;
import blaze.common.bzMath : bzVec2, bzDot;

float scalarRandomWalk(float initial, float walkspeed, float min, float max) {
	
	float next = initial + (((randomRange(0, 1) * 2) - 1) * walkspeed);
	if (next < min) return min;
	if (next > max) return max;
	return next;
}

// return component of vector perpendicular to a unit basis vector
// IMPORTANT NOTE: assumes "basis" has unit magnitude(length==1)
bzVec2 perpendicularComponent(bzVec2 vector, bzVec2 unitBasis) {
    return (vector - parallelComponent(vector, unitBasis));
}

// return component of vector parallel to a unit basis vector
// IMPORTANT NOTE: assumes "basis" has unit magnitude (length == 1)
bzVec2 parallelComponent(bzVec2 vector, bzVec2 unitBasis) {
    float projection = bzDot(vector, unitBasis);
    return unitBasis * projection;
}
        
// ----------------------------------------------------------------------------
// classify a value relative to the interval between two bounds:
//     returns -1 when below the lower bound
//     returns  0 when between the bounds (inside the interval)
//     returns +1 when above the upper bound
int intervalComparison(float x, float lowerBound, float upperBound)
{
    if (x < lowerBound) return -1;
    if (x > upperBound) return +1;
    return 0;
}

float square(float x) {
    return x * x;
}
        
T randomRange(T = int) (T min, T max)
{
    return min + Kiss.instance.natural() % (max + 1 - min);
}
