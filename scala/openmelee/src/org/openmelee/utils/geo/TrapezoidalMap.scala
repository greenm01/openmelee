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

import collection.jcl.ArrayList
import scala.collection.mutable.Map

import org.villane.vecmath.Vector2
                            
class TrapezoidalMap {

  val map: Map[Int, Trapezoid] = Map()
  
  // Add a trapezoid to the map
  def add(t: Trapezoid) {
    map + (t.hashCode -> t)
  }
  
  // Remove a trapezoid from the map
  def remove(t: Trapezoid) {
    map - t.hashCode
  }

  // Case 1: segment completely enclosed by trapezoid
  //         break trapezoid into 4 smaller traps
  def case1(t: Trapezoid, s: Segment) = {
    
    val trapezoids = new ArrayList[Trapezoid]
    val trapA = new Trapezoid(t.leftPoint, s.p, t.top, t.bottom)
    val trapB = new Trapezoid(s.p, s.q, t.top, s)
    val trapC = new Trapezoid(s.p, s.q, s, t.bottom)
    val trapD = new Trapezoid(s.q, t.rightPoint, t.top, t.bottom)
    
    trapA.update(t.upperLeft, t.lowerLeft, trapB, trapC)
    trapezoids += trapA
    trapB.update(trapA, null, trapD, null)
    trapezoids += trapB
    trapC.update(null, trapA, null, trapD)
    trapezoids += trapC
    trapC.update(trapB, trapC, t.upperRight, t.lowerRight)
    trapezoids += trapD
    
    t.updateNeighbors(trapA, trapA, trapD, trapD)
    
    trapezoids
  }

  // Case 2: Trapezoid contains point p, q lies outside
  //         Break into 3 pieces
  def case2(t: Trapezoid, s: Segment) = {
    
    val trapezoids = new ArrayList[Trapezoid]
    val trapA = new Trapezoid(t.leftPoint, s.p, t.top, t.bottom)
    val trapB = new Trapezoid(s.p, s.q, t.top, s)
    val trapC = new Trapezoid(s.p, s.q, s, t.bottom)
    
    s.above = trapB
    s.below = trapC
    
    trapA.update(t.upperLeft, t.lowerLeft, trapB, trapC)
    trapezoids += trapA
    trapB.update(trapA, null, t.upperRight, null)
    trapezoids += trapB
    trapC.update(null, trapA, null, t.lowerRight)
    trapezoids += trapC
    
    t.updateNeighbors(trapA, trapA, trapB, trapC)
    trapezoids
  }
  
  // Case 3: Trapezoid contains point q, p lies outside
  //         Break trapezoid into 3 pieces
  def case3(t: Trapezoid, s: Segment)= {
    
    val trapezoids = new ArrayList[Trapezoid]
    val trapA = new Trapezoid(s.p, s.q, t.top, s)
    val trapB = new Trapezoid(s.p, s.q, s, t.bottom)
    val trapC = new Trapezoid(s.q, t.leftPoint, t.top, t.bottom)
    
    trapA.update(t.upperLeft, s.above, trapC, null)
    trapezoids += trapA
    trapB.update(s.below, t.lowerLeft, null, trapC)
    trapezoids += trapB
    trapC.update(trapA, trapB, t.upperRight, t.lowerRight)
    trapezoids += trapC
    
    t.updateNeighbors(trapA, trapB, trapC, trapC)
    trapezoids
  }
  
  // Case 4: Trapezoid is bisected
  //         Break trapezoid into 2 pieces
  def case4(t: Trapezoid, s: Segment) = {
    
    val trapezoids = new ArrayList[Trapezoid]
    val trapA = new Trapezoid(s.p, s.q, t.top, s)
    val trapB = new Trapezoid(s.p, s.q, s, t.bottom)
    
    trapA.update(t.upperLeft, s.above, t.upperRight, null)
    trapezoids += trapA
    trapB.update(s.above, t.lowerLeft, null, t.lowerRight)
    trapezoids += trapB
    
    s.above = trapA
    s.below = trapB
    
    t.updateNeighbors(trapA, trapB, trapA, trapB)
    trapezoids
  }
  
  def boundingBox(segments: Array[Segment]): Trapezoid = {
   
    var max: Vector2 = segments(0).p
    var min: Vector2 = segments(0).q

    for(s <- segments) {
      if(s.p.x > max.x) max = Vector2(s.p.x, max.y)
      if(s.p.y > max.y) max = Vector2(max.x, s.p.y)
      if(s.q.x > max.x) max = Vector2(s.q.x, max.y)
      if(s.q.y > max.y) max = Vector2(max.x, s.q.y)
      if(s.p.x < min.x) min = Vector2(s.p.x, min.y)
      if(s.p.y < min.y) min = Vector2(min.x, s.p.y)
      if(s.q.x < min.x) min = Vector2(s.q.x, min.y)
      if(s.q.y < min.y) min = Vector2(min.x, s.q.y)
    }

    val top = new Segment(Vector2(min.x,max.y), Vector2(max.x, max.y))
    val bottom = new Segment(Vector2(min.x,min.y), Vector2(max.x, min.y))
    val left = top.p
    val right = bottom.q
    
    return new Trapezoid(left, right, top, bottom)
  }
}
