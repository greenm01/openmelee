/*
 * Trapezoid.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class Trapezoid {

  var leftPoint = Vector2.Zero
  var rightPoint = Vector2.Zero

  var top: Segment = _
  var bottom: Segment = _

  var lowerLeftNeighbor: Trapezoid = _
  var upperLeftNeighbor: Trapezoid = _
  var lowerRightNeighbor: Trapezoid = _
  var upperRightNeighbor: Trapezoid = _
  
}
