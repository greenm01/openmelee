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
    if(upperLeft != null && upperLeft.top == top) upperLeft.upperRight = ul
    if(lowerLeft != null && lowerLeft.bottom == bottom) lowerLeft.lowerRight = ll
    if(upperRight != null && upperRight.top == top) upperRight.upperLeft = ur
    if(lowerRight != null && lowerRight.bottom == bottom) lowerRight.lowerLeft = lr
  }
  
  def update(ul: Trapezoid, ll: Trapezoid, ur: Trapezoid, lr: Trapezoid) {
    upperLeft = ul
    lowerLeft = ll
    upperRight = ur
    lowerRight = lr
  }
  
  def contains(point: Vector2) = 
    (point.x >= leftPoint.x && point.x <= rightPoint.x && top > point && bottom < point)
  
  def vertices: Array[Vector2] = {
    val verts = new Array[Vector2](4)
    verts(0) = lineIntersect(top, leftPoint.x)
    verts(1) = lineIntersect(bottom, leftPoint.x)
    verts(2) = lineIntersect(bottom, rightPoint.x)
    verts(3) = lineIntersect(top, rightPoint.x)
    return verts
  }
  
  def lineIntersect(s: Segment, x: Float) = {
    // Equation of a line : y = m*x + b
    val m = (s.q.y - s.p.y) / (s.q.x - s.p.x)
    val b = s.p.y - (s.p.x * m)
    val y = m * x + b
    Vector2(x, y)
  } 
}
