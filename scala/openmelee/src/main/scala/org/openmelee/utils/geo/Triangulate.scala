/*
 * Triangulate.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee.utils.geo

import scala.collection.mutable.Map

import org.villane.vecmath.{Vector2, Preamble}

// Based on Raimund Seidel's paper "A simple and fast incremental randomized
// algorithm for computing trapezoidal decompositions and for triangulating polygons"
// See also "Computational Geometry", 3rd edition, by Mark de Berg et al, Chapter 6.2

class Triangulate(segments: Array[Segment]) {

  val trapMap: Map[Int, Trapezoid] = Map()
  val queryStruct = new QueryStructure

  // Initialize trapezoidal map and query structure
  val trap = boundingBox
  trapMap + (trap.hashCode -> trap)
  queryStruct.add(new Sink(trap))
  
  def trapezoidalMap {

  }

  def followSegment {

  }

  def boundingBox: Trapezoid = {
    
    val aabb = new Trapezoid
    var max: Vector2 = segments(0).p
    var min: Vector2 = segments(0).q

    for(s <- segments) {
      if(s.p.x > max.x) max = Vector2(s.p.x, max.y)
      if(s.p.y > max.y) max = Vector2(max.x, s.p.y)
      if(s.q.x > max.x) max = Vector2(s.q.x, max.y)
      if(s.q.y > max.y) max = Vector2(max.x, s.q.y)
      if(s.p.x < min.x) min = Vector2(s.p.x, min.y)
      if(s.p.y < min.y) min = Vector2(min.x, s.p.y)
      if(s.q.x < min.x) min = Vector2(s.q.x, min.y)
      if(s.q.y < min.y) min = Vector2(min.x, s.q.y)
    }

    aabb.top = new Segment(Vector2(min.x,max.y), Vector2(max.x, max.y))
    aabb.bottom = new Segment(Vector2(min.x,min.y), Vector2(max.x, min.y))
    aabb.leftPoint = aabb.top.p
    aabb.rightPoint = aabb.bottom.q
    
    return aabb
  }

}
