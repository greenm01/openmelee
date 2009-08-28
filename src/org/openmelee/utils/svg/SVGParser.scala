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

import scala.xml.{XML, Node}

import collection.jcl.ArrayList

import org.villane.vecmath.{Vector2}

import shapes.{Shape, Rect, Circle, Ellipse, Line, Polygon, Polyline, Path}

trait SVGParser {

  val sodipodi = "@{http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd}" + _
  val inkscape = "@{http://www.inkscape.org/namespaces/inkscape}" + _

  val layers = new ArrayList[Layer]

  def parse(fileName: String) {

    val svg = XML.load(fileName)

    for(g <- svg \\ "g") {

      val layerLabel = (g \ inkscape("label")).text
      val layer = new Layer(layerLabel)
      layers += layer

      for (r <- g \ "rect") {
        val width = (r \ "@width").text.toFloat
        val height = (r \ "@height").text.toFloat
        val rect = new Rect(width, height, pos(r))
        styleProperties(r, rect)
        layer.shapes += rect
      }

      for (r <- g \ "circle") {
        val radius = (r \ "@r").text.toFloat
        val circle = new Circle(radius, pos(r))
        styleProperties(r, circle)
        layer.shapes += circle
      }

      for (r <- g \ "ellipse") {
        val rx = (r \ "@rx").text.toFloat
        val ry = (r \ "@ry").text.toFloat
        val radius = Vector2(rx, ry)
        val ellipse = new Ellipse(radius, pos(r))
        styleProperties(r, ellipse)
        layer.shapes += ellipse
      }

      for (r <- g \ "line") {
        val x1 = (r \ "@x1").text.toFloat
        val y1 = (r \ "@y1").text.toFloat
        val x2 = (r \ "@x2").text.toFloat
        val y2 = (r \ "@y2").text.toFloat
        val start = Vector2(x1, y1)
        val end = Vector2(x2, y2)
        val line =  new Line(start, end)
        styleProperties(r, line)
        layer.shapes += line
      }

      for (r <- g \ "polygon") {
        val poly = new Polygon(points(r))
        styleProperties(r, poly)
        layer.shapes += poly
      }

      for (r <- g \ "polyline")
        layer.shapes += new Polyline(points(r))

      for (r <- g \ "path") {
        val pathData = (r \ "@d").text.split("[ ,]+")
        val path = new Path(pathData)
        path.parse
        styleProperties(r, path)
        layer.shapes += path
      }
    }
  }

  def styleProperties(node: Node, shape: Shape) {
    shape.fill = RGBColor.lookup((node \ "@fill").text)
    shape.stroke = RGBColor.lookup((node \ "@stroke").text)
    val tmp = (node \ "@stroke-width").text
    if(tmp != "") shape.strokeWidth = tmp.toFloat
  }

  def pos(node: Node) = {
    val cx = (node \ "@cx").text.toFloat
    val cy = (node \ "@cy").text.toFloat
    val pos = Vector2(cx, cy)
    pos
  }

  def points(node: Node) = {
    val points = (node \ "@points").text
    val tokens = points.split("[ ]+")
    val vecs = new Array[Vector2](tokens.length)
    var i = 0
    for(t <- tokens) {
      val token2 = t.split("[,]")
      vecs(i) = Vector2(token2(0).toFloat, token2(1).toFloat)
      i += 1
    }
    vecs
  }
}
