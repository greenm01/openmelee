/*
 * Properties.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.svg

import org.villane.box2d.draw.Color3f

/**
 * SVG Styling Properties, as defined in SVG Tiny 1.2 specification
 * http://www.w3.org/TR/SVGMobile12/styling.html
 */
trait Properties {

  var fill : Color3f = _
  var stroke : Color3f = _
  var strokeWidth : Float = _
 
}
