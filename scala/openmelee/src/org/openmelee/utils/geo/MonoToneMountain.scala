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

class MonotoneMountain(var head: Point, var tail: Point) {
  
  var size = 0
  
  def append(point: Point) {
    if(point != tail) {
      tail.next = point
      point.prev = tail
      tail = point
    }
  }
  
  def remove(point: Point) {
    val next = point.next
    val prev = point.prev
    point.prev.next = next
    point.next.prev = prev
  }
  
  // Partition a x-monotone mountain into triangles o(n)
  // See "Computational Geometry in C", 2nd edition, by Joseph O'Rourke, page 52
  def triangulate {
    /*
    println(vertices.size)
    val convexVertices = new Stack[Point]
    val triList = new ArrayList[Array[Point]]
    var i = 1
    while(i < vertices.size - 2) {
      if(convex(vertices(i-1), vertices(i), vertices(i+1)))
        convexVertices.push(vertices(i))
      i += 1
    }
    
    i = 0
    while(convexVertices.size > 0) {
      val v = convexVertices.pop
      println(v)
    }
    */
  }
  
}
