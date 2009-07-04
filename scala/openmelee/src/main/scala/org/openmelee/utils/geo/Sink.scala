/*
 * Sink.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

class Sink(val trapezoid: Trapezoid) extends Node {

  def hash = trapezoid.hashCode
  def locate(p: Vector2) = this
  
}
