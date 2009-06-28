/*
 * circle.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.svg.shapes

import org.villane.vecmath.Vector2
import org.villane.box2d.draw.Color3f

class Circle(radius: Float, center: Vector2) extends Shape {

  override def render() {
    draw.circle(center, radius, Color3f(255, 0, 0))
  }
}
