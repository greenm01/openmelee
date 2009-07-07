/*
 * Trapezoid.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class Trapezoid(val leftPoint: Vector2, val rightPoint: Vector2, val top: Segment, val bottom: Segment) {

  // Neighbor pointers
  var upperLeft: Trapezoid = _
  var lowerLeft: Trapezoid = _
  var upperRight: Trapezoid = _
  var lowerRight: Trapezoid = _
  
  def updateNeighbors(ul: Trapezoid, ll: Trapezoid, ur: Trapezoid, lr: Trapezoid) {
    if(upperRight != null) upperLeft.upperRight = ul
    if(lowerRight != null) lowerLeft.lowerRight = ll
    if(upperLeft != null) upperRight.upperLeft = ur
    if(lowerLeft != null) lowerRight.lowerLeft = lr
  }
  
  def update(ul: Trapezoid, ll: Trapezoid, ur: Trapezoid, lr: Trapezoid) {
    upperLeft = ul
    lowerLeft = ll
    upperRight = ur
    lowerRight = lr
  }
}
