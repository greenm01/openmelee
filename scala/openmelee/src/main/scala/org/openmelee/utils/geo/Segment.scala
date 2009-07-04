/*
 * Segment.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class Segment(val p: Vector2, val q: Vector2) {

  def >= (point: Vector2) = (p.y > point.y && q.y > point.y)
  
}
