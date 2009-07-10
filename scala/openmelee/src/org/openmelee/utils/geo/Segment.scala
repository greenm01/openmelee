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

import collection.jcl.ArrayList

// Represents a simple polygon's edge
class Segment(var p: Vector2, var q: Vector2) {

  // List of trapezoids this segment constitutes either the 
  // top or bottom edge
  val trapezoids = new ArrayList[Trapezoid]
  // Pointer used for building trapezoidal map
  var above: Trapezoid = null

  // Equation of a line: y = m*x + b
  // Slope of the line (m)
  val slope = (q.y - p.y)/(q.x - p.x)
  // Y intercept
  val b = p.y - (p.x * slope)
  
  // Determines if this segment lies above the given point
  def > (point: Vector2) = (point.y < slope * point.x + b)
  // Determines if this segment lies below the given point
  def < (point: Vector2) = (point.y > slope * point.x + b) 
  // Add trapezoid the the pointer list
  def addTrapezoid(t: Trapezoid) = trapezoids += t
  // Remove trapezoid from pointer list
  def removeTrapezoid(t: Trapezoid) = trapezoids -= t
}
