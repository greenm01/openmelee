/*
 * render.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.render

import java.util.ArrayList
import java.nio.FloatBuffer

import org.villane.box2d.draw.Color3f
import org.villane.vecmath.Vector2
import org.villane.box2d.shapes.Shape
import org.villane.box2d.shapes.Polygon
import org.villane.vecmath.Transform2
import org.villane.box2d.dynamics.World

import org.lwjgl.opengl.GL11
import org.lwjgl.BufferUtils
import org.lwjgl.opengl.ARBVertexBufferObject

import org.lwjgl.opengl.GLContext

import melee.Melee

trait RenderG11 {

  // Save current matrix (as set by glMatrixMode)
  def pushMatrix {
    GL11.glPushMatrix
    // Reset The Current Modelview Matrix
    GL11.glLoadIdentity
    GL11.glEnable(GL11.GL_LINE_SMOOTH)
    GL11.glEnable(GL11.GL_BLEND)
    GL11.glDepthMask(false)
  }

  // Restore saved matrix
  def popMatrix {
    GL11.glPopMatrix
  }

  def scale(zoom: Float) {
    GL11.glScalef(zoom, zoom, 1f)
  }

  def rotate(angle: Float, center: Vector2) {
    translate(center)
    GL11.glRotatef(angle, 0f, 0f, 1f)
    translate(-center)
  }

  def translate(pos: Vector2) {
    GL11.glTranslatef(pos.x, pos.y, 0f)
  }
  
  // Vertex array
  def renderVA(points: FloatBuffer, style: Int) {
    GL11.glEnableClientState(GL11.GL_VERTEX_ARRAY)
    GL11.glVertexPointer(2, 0, points)
    val size = (points.capacity*0.5).toInt
    GL11.glDrawArrays(style, 0, size)
    GL11.glDisableClientState(GL11.GL_VERTEX_ARRAY)
  }

  def color = glColor
  def color_=(color: Color3f) {
    GL11.glColor3f(color.r, color.g, color.b)
    glColor = color
  }
  
  def lineWidth(width: Float) {
    GL11.glLineWidth(width)
  }

  def bezierQuadratic(v1: Vector2, v2: Vector2, v3: Vector2) {

    // Variable
    var a = 1.0f
    var b = 1.0f - a

    GL11.glColor3f(255f, 0, 0)
    GL11.glLineWidth(2f)

    // Tell OGL to start drawing a line strip
    GL11.glBegin(GL11.GL_LINE_STRIP)
    for(i <- 0 to 20) {
      // Get a point on the curve
      val X = v1.x*a*a + v2.x*2*a*b + v3.x*b*b
      val Y = v1.y*a*a + v2.y*2*a*b + v3.y*b*b
      GL11.glVertex2f(X, Y)
      a -= 0.05f
      b = 1.0f - a
    }
    GL11.glEnd
  }

  def bezierCubic {

    // Control points (example)
    val Ax = 100; val Ay = 100
    val Bx = 100; val By = 300.0
    val Cx = 200.0; val Cy = 100.0
    val Dx = 200.0; val Dy = 300.0

    // Variable
    var a = 1.0
    var b = 1.0 - a

    GL11.glColor3f(255f, 0, 0)
    GL11.glLineWidth(2f)

    // Tell OGL to start drawing a line strip
    GL11.glBegin(GL11.GL_LINE_STRIP) 
    for(i <- 0 to 20) {
      // Get a point on the curve
      val X = Ax*a*a*a + Bx*3*a*a*b + Cx*3*a*b*b + Dx*b*b*b
      val Y = Ay*a*a*a + By*3*a*a*b + Cy*3*a*b*b + Dy*b*b*b
      GL11.glVertex2d(X, Y)
      a -= 0.05
      b = 1.0 - a
    }
    GL11.glEnd
  }

  /*
  def createVBOID() = {
    if (GLContext.getCapabilities.GL_ARB_vertex_buffer_object) {
      val buffer = BufferUtils.createIntBuffer(1)
      ARBVertexBufferObject.glGenBuffersARB(buffer)
      buffer.get(0)
    } else {
      0
    }
  }

  def bufferData(id: Int, buffer: FloatBuffer) {
		ARBVertexBufferObject.glBindBufferARB(ARBVertexBufferObject.GL_ARRAY_BUFFER_ARB, id);
		ARBVertexBufferObject.glBufferDataARB(ARBVertexBufferObject.GL_ARRAY_BUFFER_ARB, buffer, ARBVertexBufferObject.GL_STATIC_DRAW_ARB);
	}
  */
 
  private[this] var glColor: Color3f = _
}
