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
    
  def isLeft(a: Vector2f, b: Vector2f, c: Vector2f) =
    (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y)


  // Melkman's Algorithm
  // Return a convex hull in ccw order
  def hull(V: Array[Vector2f]) = {

    val n = V.length
    val D = new Array[Vector2f](2 * n + 1)
    var bot = n - 2
    var top = bot + 3

    D(bot) = V(2)
    D(top) = V(2)

    if (isLeft(V(0), V(1), V(2)) > 0) {
      D(bot+1) = V(0)
      D(bot+2) = V(1)
    } else {
      D(bot+1) = V(1)
      D(bot+2) = V(0)
    }

    var i = 3
    while(i < n) {
      if (!(isLeft(D(bot), D(bot+1), V(i)) > 0) &&
          !(isLeft(D(top-1), D(top), V(i)) > 0)) {
        while (isLeft(D(bot), D(bot+1), V(i)) <= 0) bot += 1
        bot -= 1
        D(bot) = V(i)
        while (isLeft(D(top-1), D(top), V(i)) <= 0) top -= 1
        top += 1
        D(top) = V(i)
      }
      i += 1
    }

    val H = new Array[Vector2f](n)
    var h = 0
    while(h <= (top - bot)) {
      H(h) = D(bot + h)
      h += 1
    }
    D.foreach(println)
    H
  }

  def svgToWorld(points: Array[Float], scale: Float) = {
    var i = 0
    var j = 0
    val bridgeVerts = new Array[Vector2f](points.length/2)
    while(i < bridgeVerts.length) {
      bridgeVerts(i) = worldPoint(points(j), points(j+1), scale)
      i += 1
      j += 2
    }
    bridgeVerts
  }

  def worldPoint(x: Float, y: Float, scale: Float) = {
    val p = Vector2f(x*scale,y*scale)
    p
  }

}
