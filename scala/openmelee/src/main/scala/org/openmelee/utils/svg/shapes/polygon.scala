/*
 * polygon.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.svg.shapes

import org.villane.vecmath.Vector2

import org.lwjgl.BufferUtils
import org.lwjgl.opengl.GL11

class Polygon(vertices: Array[Vector2]) extends Shape {

  val points = BufferUtils.createFloatBuffer(vertices.length*2)

  for(v <- vertices) {
    points.put(v.x)
    points.put(v.y)
    println(v)
  }

  points.rewind

  override def render {
    pushMatrix
    scale(0.5f)
    //rotate(45f, center)
    color = stroke
    lineWidth(strokeWidth*0.5f)
    renderVA(points, GL11.GL_LINE_LOOP)
    // TODO: Add OpenGL Tessellation for non-convex polygons
    //color = fill
    //renderVA(points, GL11.GL_POLYGON)
    popMatrix
  }

  }
