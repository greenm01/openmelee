/*
 * XNode.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class XNode(point: Vector2, left: Node, right: Node) extends Node {

  def locate(s: Segment) = {
    if(s.p.x >= point.x) {
      right.locate(s)
    } else {
      left.locate(s)
    }
  }

}
