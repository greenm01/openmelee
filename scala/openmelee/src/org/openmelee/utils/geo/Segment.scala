/*
 * Segment.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class Segment(val p: Vector2, val q: Vector2) {

  var above: Trapezoid = _
  var below: Trapezoid = _
  
  def > (point: Vector2) = (p.y > point.y && q.y > point.y)
  def < (point: Vector2) = (p.y < point.y && q.y < point.y)
  def slope = (q.y - p.y)/(q.x - p.x)
  
}
