/*
 * circle.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee.utils.svg.shapes

import org.lwjgl.BufferUtils
import org.lwjgl.opengl.GL11

import org.villane.vecmath.Vector2
import org.villane.box2d.draw.Color3f

class Circle(radius: Float, center: Vector2) extends Shape {

  val SEGMENTS = 25
  val points = BufferUtils.createFloatBuffer(SEGMENTS*2)
  init
  
  def init {
    val k_increment = 2.0f * Math.Pi.toFloat / SEGMENTS
    var theta = 0.0f
    for (i <- 0 until SEGMENTS) {
      val v = center + Vector2(Math.cos(theta).toFloat, Math.sin(theta).toFloat) * radius
      points.put(v.x)
      points.put(v.y)
      theta += k_increment
    }
    points.rewind
  }

  override def render {
    pushMatrix
    scale(0.5f)
    rotate(45f, center)
    color = fill
    renderVA(points, GL11.GL_TRIANGLE_FAN)
    color = stroke
    lineWidth(strokeWidth*0.5f)
    renderVA(points, GL11.GL_LINE_LOOP)
    popMatrix
  }

}
