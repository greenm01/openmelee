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

import shapes.{Rect, Circle, Ellipse, Line, Polygon, Polyline, Path}

class SVGParser(fileName: String) {

  val sodipodi = "@{http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd}" + _
  val inkscape = "@{http://www.inkscape.org/namespaces/inkscape}" + _

  val layers = new ArrayList[Layer]

  def parse {

    val svg = XML.load(fileName)

    for(g <- svg \\ "g") {

      val layerLabel = (g \ inkscape("label")).text
      val layer = new Layer(layerLabel)
      layers += layer

      for (r <- g \ "rect") {
        val width = (r \ "@width").text.toFloat
        val height = (r \ "@height").text.toFloat
        layer.shapes += new Rect(width, height, pos(r))
      }

      for (r <- g \ "circle") {
        val radius = (r \ "@r").text.toFloat
        layer.shapes += new Circle(radius, pos(r))
      }

      for (r <- g \ "ellipse") {
        val rx = (r \ "@rx").text.toFloat
        val ry = (r \ "@ry").text.toFloat
        val radius = Vector2(rx, ry)
        layer.shapes += new Ellipse(radius, pos(r))
      }

      for (r <- g \ "line") {
        val x1 = (r \ "@x1").text.toFloat
        val y1 = (r \ "@y1").text.toFloat
        val x2 = (r \ "@x2").text.toFloat
        val y2 = (r \ "@y2").text.toFloat
        val start = Vector2(x1, y1)
        val end = Vector2(x2, y2)
        layer.shapes += new Line(start, end)
      }

      for (r <- g \ "polygon") 
        layer.shapes += new Polygon(points(r))

      for (r <- g \ "polyline")
        layer.shapes += new Polyline(points(r))

      for (path <- g \ "path") {
        val pathData = (path \ "@d").text.split("[ ,]+")
        val p = new Path(pathData)
        p.parse
        layer.shapes += p
        p.vertices.foreach(println)
      }
    }
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
