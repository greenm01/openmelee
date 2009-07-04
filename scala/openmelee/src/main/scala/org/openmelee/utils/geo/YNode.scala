/*
 * YNode.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

import org.villane.vecmath.Vector2

class YNode(point: Vector2, above: Node, below: Node) extends Node {

  def locate(p: Vector2) = {
    if(p.x >= point.x) {
      above.locate(p)
    } else {
      below.locate(p)
    }
  }

}
