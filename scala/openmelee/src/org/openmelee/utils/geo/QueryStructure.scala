/*
 * QueryStructure.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.geo

import org.villane.vecmath.Vector2

// Directed Acyclitic Graph (DAG)
class QueryStructure(head: Node) {

  def add(sink: Sink) {

  }

  def locate(s: Segment) = {
    val sink = head.locate(s).asInstanceOf[Sink]
    sink.trapezoid
  }

}
