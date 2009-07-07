/*
 * RBGColor.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.svg

import org.villane.box2d.draw.Color3f

// As defined in the SVG Tiny 1.2 specification
// http://www.w3.org/TR/SVGMobile12/painting.html

object RGBColor {
  
  def red = Color3f(255, 0, 0)
  def green = Color3f(0, 255, 0)
  def blue = Color3f(0, 0, 255)
  def black = Color3f(0, 0, 0)
  def silver = Color3f(192, 192, 192)
  def gray = Color3f(128, 128, 128)
  def white = Color3f(255, 255, 255)
  def maroon = Color3f(128, 0, 0)
  def purple = Color3f(128, 0, 128)
  def fuchsia = Color3f(255, 0, 255)
  def lime = Color3f(0, 255, 0)
  def olive = Color3f(128, 128, 0)
  def yellow = Color3f(255, 255, 0)
  def navy = Color3f(0, 0, 128)
  def teal = Color3f(0, 128, 128)
  def aqua = Color3f(0, 255, 255)

  def lookup(color: String): Color3f =
    color match {
      case "red" => red
      case "green" => green
      case "blue" => blue
      case "black" => black
      case "silver" => silver
      case "gray" => gray
      case "white" => white
      case "maroon" => maroon
      case "purple" => purple
      case "fuchsia" => fuchsia
      case "lime" => lime
      case "olive" => olive
      case "yellow" => yellow
      case "navy" => navy
      case "teal" => teal
      case "aqua" => aqua
      case _ => red
    }
}
