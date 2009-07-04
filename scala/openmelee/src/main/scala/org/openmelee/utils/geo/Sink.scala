/*
 * Sink.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

class Sink(trapezoid: Trapezoid) extends Node {

  def hash = trapezoid.hashCode
  
}
