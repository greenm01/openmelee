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
package org.openmelee.utils.svg.shapes

import org.villane.vecmath.Vector2

import java.nio.FloatBuffer

import org.lwjgl.BufferUtils
import org.lwjgl.opengl.GL11

import utils.geo.Triangulator

class Polygon(vertices: Array[Vector2]) extends Shape {
 
  //val poly2tri = new Triangulate
  //val triList = poly2tri.process(vertices)

  val points = BufferUtils.createFloatBuffer(vertices.length*2)

  /*
  val triangles = new Array[FloatBuffer]((triList.length/3))

  var k = 0
  for(i <- 0 until triangles.length) {
    val triPoints = BufferUtils.createFloatBuffer(3*2)
    for(j <- 1 to 3) {
      triPoints.put(triList(k).x)
      triPoints.put(triList(k).y)
      k+=1
    }
    triPoints.rewind
    triangles(i) = triPoints
  }
  */

  vertices.foreach(v => {points.put(v.x); points.put(v.y)})
  points.rewind

  override def render {
    pushMatrix
    scale(0.5f)
    /*
    color = fill
    for(t <- triangles)
      renderVA(t, GL11.GL_TRIANGLES)
    */
    color = stroke
    lineWidth(strokeWidth*0.5f)
    renderVA(points, GL11.GL_LINE_LOOP)
    popMatrix
  }
}
