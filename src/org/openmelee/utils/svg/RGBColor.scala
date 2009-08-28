/* OpenMelee
 * Copyright (c) 2009, Mason Green
 * http://github.com/zzzzrrr/openmelee
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of OpenMelee nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
