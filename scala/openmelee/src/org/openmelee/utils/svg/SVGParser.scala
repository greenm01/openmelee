/*
 * SVGParser.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
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
