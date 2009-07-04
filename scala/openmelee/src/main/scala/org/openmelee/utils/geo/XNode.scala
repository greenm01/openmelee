/*
 * XNode.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class XNode(segment: Segment, left: Node, right: Node) extends Node {

  def locate(p: Vector2) = {
    if(segment >= p) {
      left.locate(p)
    } else {
      right.locate(p)
    }
  }

}
