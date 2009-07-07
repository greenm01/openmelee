/*
 * YNode.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

import org.villane.vecmath.Vector2

class YNode(segment: Segment, above: Node, below: Node) extends Node {

  def locate(s: Segment) = {
    if (segment > s.p) {
      below.locate(s)
    } else if (segment < s.p){
      above.locate(s)
    } else {
      // s and segment share the same endpoint
      s.above = segment.above
      s.below = segment.below
      if (s.slope < segment.slope) {
        below.locate(s)
      } else {
        above.locate(s)
      }
    }
  }

}
