/*
 * render.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.render

import java.util.ArrayList

import org.villane.box2d.draw.Color3f
import org.villane.vecmath.Vector2
import org.villane.box2d.shapes.Shape
import org.villane.box2d.shapes.Polygon
import org.villane.vecmath.Transform2
import org.villane.box2d.dynamics.World

import org.lwjgl.opengl.GL11

import melee.Melee

class Render() {

  def bezierQuadratic {
    // Control points (example)
    val Ax = 400; val Ay = 100
    val Bx = 500; val By = 300.0
    val Cx = 400.0; val Cy = 500.0

    // Variable
    var a = 1.0
    var b = 1.0 - a

    GL11.glColor3f(255f, 0, 0)
    GL11.glLineWidth(2f)

    // Tell OGL to start drawing a line strip
    GL11.glBegin(GL11.GL_LINE_STRIP)
      for(i <- 0 to 20) {
        // Get a point on the curve
        val X = Ax*a*a + Bx*2*a*b + Cx*b*b
        val Y = Ay*a*a + By*2*a*b + Cy*b*b
        GL11.glVertex2d(X, Y)
        a -= 0.05
        b = 1.0 - a
      }
    GL11.glEnd()
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
    GL11.glEnd()

  }

}
