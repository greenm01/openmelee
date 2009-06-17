/*
 * util.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils

import org.villane.vecmath.Vector2f

object Util {

  @inline def rotateLeft90(v:Vector2f) = new Vector2f( -v.y, v.x )

  @inline def rotateRight90(v:Vector2f) = new Vector2f(v.y, -v.x )

  @inline def rotate(v:Vector2f, angle:Float) = {
    val cos = Math.cos(angle).asInstanceOf[Float]
    val sin = Math.sin(angle).asInstanceOf[Float]
    val u = new Vector2f((cos * v.x) - (sin * v.y), (cos * v.y) + (sin * v.x))
    u
  }
    
  def left(a: Vector2f, b: Vector2f, c: Vector2f) =
    ((b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y) > 0)

  /** Melkman's Algorithm
   *  www.ams.sunysb.edu/~jsbm/courses/345/melkman.pdf
   *  Return a convex hull in ccw order
   */
  def hull(V: Array[Vector2f]) = {

    val n = V.length
    val D = new Array[Vector2f](2 * n + 1)
    var bot = n - 2
    var top = bot + 3

    D(bot) = V(2)
    D(top) = V(2)

    if (left(V(0), V(1), V(2))) {
      D(bot+1) = V(0)
      D(bot+2) = V(1)
    } else {
      D(bot+1) = V(1)
      D(bot+2) = V(0)
    }

    var i = 3
    while(i < n) {
      while (left(D(bot), D(bot+1), V(i)) && left(D(top-1), D(top), V(i))) {
        i += 1
      }
      while (!left(D(top-1), D(top), V(i))) top -= 1
      top += 1; D(top) = V(i)
      while (!left(D(bot), D(bot+1), V(i))) bot += 1
      bot -= 1; D(bot) = V(i)
      i += 1
    }

    val H = new Array[Vector2f](top - bot)
    var h = 0
    while(h < (top - bot)) {
      H(h) = D(bot + h)
      h += 1
    }
    H
  }

  def svgToWorld(points: Array[Float], scale: Float) = {
    val verts = new Array[Vector2f](points.length/2)
    var i = 0
    while(i < verts.length) {
      verts(i) = worldPoint(points(i*2), points(i*2+1), scale)
      i += 1
    }
    verts
  }

  def worldPoint(x: Float, y: Float, scale: Float) = {
    val p = Vector2f(x*scale, y*scale)
    p
  }

}
