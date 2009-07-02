/*
 * svg.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee.utils.svg

class SVG(filename: String) extends SVGParser {

  parse(filename)

  def render {
    for(layer <- layers) {
      for(shape <- layer.shapes) {
        shape render
      }
    }
  }

}
