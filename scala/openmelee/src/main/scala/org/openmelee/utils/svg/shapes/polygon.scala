/*
 * polygon.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee.utils.svg.shapes

import org.villane.vecmath.Vector2

import java.nio.FloatBuffer

import org.lwjgl.BufferUtils
import org.lwjgl.opengl.GL11

import utils.geo.Triangulate

class Polygon(vertices: Array[Vector2]) extends Shape {

  vertices.foreach(println)
  
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
