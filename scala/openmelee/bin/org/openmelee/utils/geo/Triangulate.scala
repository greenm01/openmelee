/*
 * Triangulate.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee.utils.geo

import collection.jcl.ArrayList
import scala.collection.mutable.Map

import org.villane.vecmath.{Vector2, Preamble}

// Based on Raimund Seidel's paper "A simple and fast incremental randomized
// algorithm for computing trapezoidal decompositions and for triangulating polygons"
// See also "Computational Geometry", 3rd edition, by Mark de Berg et al, Chapter 6.2

class Triangulate(segments: Array[Segment]) {

  // TODO: Randomize segment list

  // Initialize trapezoidal map and query structure
  val trapMap: Map[Int, Trapezoid] = Map()
  val trap = boundingBox
  trapMap + (trap.hashCode -> trap)
  val queryStruct = new QueryStructure(new Sink(trap))

  def process {
    
  }
  
  def trapezoidalMap {
    for(s <- segments) {
      val trapSet = followSegment(s)
      val newTraps = new ArrayList[ArrayList[Trapezoid]]
      for(t <- trapSet) trapMap - t.hashCode
      if(trapSet.size == 1) {
        // Case 1
        //newTraps += partitionTrapezoid(trapSet(0), s)
      } else {
        // Case 2 and 3
        for(t <- trapSet) {
          //val p = point(t, s)
          // newTraps += partitionTrapezoid(t, p)
        }
      }
      for(tList <- newTraps) {
        for(t <- tList) {
          trapMap + (t.hashCode -> t)
        }
      }
    }
  }

  def followSegment(s: Segment) = {
    val trapezoids = new ArrayList[Trapezoid]
    trapezoids += queryStruct.locate(s)
    var j = 0
    while(s.q.x > trapezoids(j).rightPoint.x) {
      if(s > trapezoids(j).rightPoint) {
        trapezoids += trapezoids(j).upperRight
      } else {
        trapezoids += trapezoids(j).lowerRight
      }
      j += 1
    }
    trapezoids
  }

  // Case 1: segment completely enclosed by trapezoid
  //         break trapezoid into 4 smaller traps
  def case1(t: Trapezoid, s: Segment) = {
    val trapList = new ArrayList[Trapezoid]
    val trapA = new Trapezoid(t.leftPoint, s.p, t.top, t.bottom)
    val trapB = new Trapezoid(s.p, s.q, t.top, s)
    val trapC = new Trapezoid(s.p, s.q, s, t.bottom)
    val trapD = new Trapezoid(s.q, t.rightPoint, t.top, t.bottom)
    trapA.update(t.upperLeft, t.lowerLeft, trapB, trapC)
    trapList += trapA
    trapB.update(trapA, null, trapD, null)
    trapList += trapB
    trapC.update(null, trapA, null, trapD)
    trapList += trapC
    trapC.update(trapB, trapC, t.upperRight, t.lowerRight)
    trapList += trapD
    t.updateNeighbors(trapD, trapD, trapA, trapA)
    
    trapList
  }

  // Case 2: Trapezoid contains point p, q lies outside
  //         Break into 3 pieces
  def case2(t: Trapezoid, s: Segment) = {
    
    val trapList = new ArrayList[Trapezoid]
    val trapA = new Trapezoid(t.leftPoint, s.p, t.top, t.bottom)
    val trapB = new Trapezoid(s.p, s.q, t.top, s)
    val trapC = new Trapezoid(s.p, s.q, s, t.bottom)
    
    s.above = trapB
    s.below = trapC
    
    trapA.update(t.upperLeft, t.lowerLeft, trapB, trapC)
    trapList += trapA
    trapB.update(trapA, null, t.upperRight, null)
    trapList += trapB
    trapC.update(null, trapA, null, t.lowerRight)
    trapList += trapC
    t.updateNeighbors(trapA, trapA)
    
    trapList
  }
  
  // Case 3: Trapezoid contains point q, p lies outside
  //         Break trapezoid into 3 pieces
  def case3(t: Trapezoid, s: Segment)= {
    
    val trapList = new ArrayList[Trapezoid]
    val trapA = new Trapezoid(t.leftPoint, s.p, t.top, t.bottom)
    val trapB = new Trapezoid(s.p, s.q, t.top, s)
    val trapC = new Trapezoid(s.p, s.q, s, t.bottom)
    
    trapA.update(t.upperLeft, s.above, trapC, null)
    trapList += trapA
    trapB.update(s.below, t.lowerLeft, null, trapC)
    trapList += trapB
    trapC.update(trapA, trapB, t.upperRight, t.lowerRight)
    trapList += trapC
    t.updateNeighbors(trapC, trapC, trapA, trapB)
    
    trapList
  }
  
  // Case 4: Trapezoid is bisected
  //         Break trapezoid into 2 pieces
  def case4(t: Trapezoid, s: Segment): ArrayList[Trapezoid] = {
    return new ArrayList[Trapezoid]
  }

  def boundingBox: Trapezoid = {
   
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

    val top = new Segment(Vector2(min.x,max.y), Vector2(max.x, max.y))
    val bottom = new Segment(Vector2(min.x,min.y), Vector2(max.x, min.y))
    val left = top.p
    val right = bottom.q
    
    val aabb = new Trapezoid(left, right, top, bottom)
    return aabb
  }

}
