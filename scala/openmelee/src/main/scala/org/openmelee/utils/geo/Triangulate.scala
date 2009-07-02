/*
 * Triangulate.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee.utils.geo

import collection.jcl.ArrayList
import org.villane.vecmath.Vector2

// Modified from John W. Ratfliff's C++ implementation
// http://www.flipcode.com/archives/Efficient_Polygon_Triangulation.shtml

class Triangulate {

  val EPSILON = 0.0000000001f
  
  def area (contour: Array[Vector2]): Float = {
    val n = contour.length
    var a = 0f
    var p = n-1
    var q = 0
    while(q < n) {
      a += contour(p).x * contour(q).y - contour(q).x * contour(p).y
      p = q; q += 1
    }
    return a*0.5f
  }

  /*
   InsideTriangle decides if a point P is Inside of the triangle
   defined by A, B, C.
   */
  def insideTriangle(A: Vector2, B: Vector2, C: Vector2, P: Vector2) = {
    val a = C - B
    val b = A - C
    val c = B - A
    val ap = P - A
    val bp = P - B
    val cp = P - C
    val aCROSSbp = a.cross(bp)
    val cCROSSap = c.cross(ap)
    val bCROSScp = b.cross(cp)
    ((aCROSSbp >= 0f) && (bCROSScp >= 0f) && (cCROSSap >= 0f))
  }

  def snip(contour: Array[Vector2], u: Int, v: Int, w: Int, n: Int, V: Array[Int]): Boolean = {
    val A = contour(V(u))
    val B = contour(V(v))
    val C = contour(V(w))
    var result = false
    if ( EPSILON > (((B.x-A.x)*(C.y-A.y)) - ((B.y-A.y)*(C.x-A.x))) ) return false
    for (p <- 0 until n) {
      if( !((p == u) || (p == v) || (p == w)) ) {
        val P = contour(V(p))
        if (insideTriangle(A, B, C, P)) return false
      }
    }
    return true
  }

  def process(contour: Array[Vector2]): ArrayList[Vector2] = {
    println("process")
    /* allocate and initialize list of Vertices in polygon */

    val n = contour.length
    if ( n < 3 ) return null

    val result = new ArrayList[Vector2]
    val V = new Array[Int](n)

    /* we want a counter-clockwise polygon in V */

    if (0.0f < area(contour)) {
      for(v <- 0 until n) V(v) = v
    } else {
      for(v <- 0 until n) V(v) = (n-1)-v
    }

    var nv = n
    /*  remove nv-2 Vertices, creating 1 triangle every time */
    var count = 2 * nv  /* error detection */

    var m = 0
    var v = nv - 1
    while(nv > 2) {
      
      /* if we loop, it is probably a non-simple polygon */
      if (0 >= (count-1)) {
        //** Triangulate: ERROR - probable bad polygon!
        return null
      }

      /* three consecutive vertices in current polygon, <u,v,w> */
      var u = v; if (nv <= u) u = 0     /* previous */
      v = u+1; if (nv <= v) v = 0       /* new v    */
      var w = v+1; if (nv <= w) w = 0   /* next     */

      if ( snip(contour,u,v,w,nv,V) ) {

        /* true names of the vertices */
        val a = V(u); val b = V(v); val c = V(w);

        /* output Triangle */
        result += contour(a)
        result += contour(b)
        result += contour(c)

        m += 1

        /* remove v from remaining polygon */
        var s = v
        var t = v + 1
        while(t < nv) {
          V(s) = V(t); nv -= 1
          s += 1; t += 1
        }

        /* resest error detection counter */
        count = 2 * nv
      }
    }
    result
  }
}
