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
package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class Trapezoid(val leftPoint: Vector2, var rightPoint: Vector2, val top: Segment, val bottom: Segment) {

  var sink: Sink = null
  
  // Neighbor pointers
  var upperLeft: Trapezoid = null
  var lowerLeft: Trapezoid = null
  var upperRight: Trapezoid = null
  var lowerRight: Trapezoid = null
  
  def updateNeighbors(ul: Trapezoid, ll: Trapezoid, ur: Trapezoid, lr: Trapezoid) {
    if(upperRight != null) upperLeft.upperRight = ul
    if(lowerRight != null) lowerLeft.lowerRight = ll
    if(upperLeft != null) upperRight.upperLeft = ur
    if(lowerLeft != null) lowerRight.lowerLeft = lr
  }
  
  def update(ul: Trapezoid, ll: Trapezoid, ur: Trapezoid, lr: Trapezoid) {
    upperLeft = ul
    lowerLeft = ll
    upperRight = ur
    lowerRight = lr
  }
  
  def contains(point: Vector2) = 
    (point.x > leftPoint.x && point.x < rightPoint.x && top > point && bottom < point)
  
  def contains(segment: Segment) = 
    (segment < rightPoint && segment > leftPoint && segment < top && segment > bottom)
  
  def vertices: Array[Vector2] = {
    val verts = new Array[Vector2](4)
    verts(0) = closestPtSegment(top.p, top.q, leftPoint)
    verts(1) = closestPtSegment(bottom.p, bottom.q, leftPoint)
    verts(2) = closestPtSegment(bottom.p, bottom.q, rightPoint)
    verts(3) = closestPtSegment(top.p, top.q, rightPoint)
    return verts
  }
  
  // From Christer Ericson’s Real-time Collision Detection 
  // Finds the closest point on segment to point c
  def closestPtSegment(c: Vector2, a: Vector2, b: Vector2) = {

    val ab = b - a;
    var d = Vector2.Zero
    
    var t = (c - a).dot(ab);
    if (t <= 0.0f) {
    	t = 0.0f
    	d = a
    } else {
    	val denom = ab.dot(ab)
    	if (t >= denom) {
    		t = 1.0f
    		d = b
    	} else {
    		t = t / denom
    		d = a + ab * t
    	}
    }
    d 
  }
 
}
