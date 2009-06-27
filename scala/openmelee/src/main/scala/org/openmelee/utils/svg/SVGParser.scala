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

import shapes.{Rect, Circle, Ellipse, Line, Polygon, Polyline}

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

      for (r <- g \ "polygon") {
        layer.shapes += new Polygon(points(r))
      }

      for (r <- g \ "polyline")
      layer.shapes += new Polyline(points(r))

      for (path <- g \ "path") {
        val pathData = (path \ "@d").text.split("[ ,]+")
        var i = 0
        while(i < pathData.length) {
          pathData(i) match {
            case "M" =>  // M - move to (absolute)
              //cx = PApplet.parseFloat(pathDataKeys[i + 1])
              //cy = PApplet.parseFloat(pathDataKeys[i + 2])
              //parsePathMoveto(cx, cy)
              i += 3
            case "m" =>  // m - move to (relative)
              //cx = cx + PApplet.parseFloat(pathDataKeys[i + 1])
              //cy = cy + PApplet.parseFloat(pathDataKeys[i + 2])
              //parsePathMoveto(cx, cy)
              i += 3
            case "L" =>
              //cx = PApplet.parseFloat(pathDataKeys[i + 1])
              //cy = PApplet.parseFloat(pathDataKeys[i + 2])
              //parsePathLineto(cx, cy)
              i += 3
            case "l" =>
              //cx = cx + PApplet.parseFloat(pathDataKeys[i + 1])
              //cy = cy + PApplet.parseFloat(pathDataKeys[i + 2])
              //parsePathLineto(cx, cy)
              i += 3;
            case "H" =>
              //cx = PApplet.parseFloat(pathDataKeys[i + 1])
              //parsePathLineto(cx, cy)
              i += 2;
            case "h" =>
              //cx = cx + PApplet.parseFloat(pathDataKeys[i + 1])
              //parsePathLineto(cx, cy)
              i += 2;
            case "V" =>
              //cy = PApplet.parseFloat(pathDataKeys[i + 1])
              //parsePathLineto(cx, cy)
              i += 2;
            case "v" =>
              //cy = cy + PApplet.parseFloat(pathDataKeys[i + 1])
              //parsePathLineto(cx, cy)
              i += 2;
            case "C" =>
              /*
               val ctrlX1 = PApplet.parseFloat(pathDataKeys[i + 1])
               val ctrlY1 = PApplet.parseFloat(pathDataKeys[i + 2])
               val ctrlX2 = PApplet.parseFloat(pathDataKeys[i + 3])
               val ctrlY2 = PApplet.parseFloat(pathDataKeys[i + 4])
               val endX = PApplet.parseFloat(pathDataKeys[i + 5])
               val endY = PApplet.parseFloat(pathDataKeys[i + 6])
               parsePathCurveto(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
               cx = endX;
               cy = endY;
               */
              i += 7;
            case "c" =>
              /*
               val ctrlX1 = cx + PApplet.parseFloat(pathDataKeys[i + 1])
               val ctrlY1 = cy + PApplet.parseFloat(pathDataKeys[i + 2])
               val ctrlX2 = cx + PApplet.parseFloat(pathDataKeys[i + 3])
               val ctrlY2 = cy + PApplet.parseFloat(pathDataKeys[i + 4])
               val endX = cx + PApplet.parseFloat(pathDataKeys[i + 5])
               val endY = cy + PApplet.parseFloat(pathDataKeys[i + 6])
               parsePathCurveto(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
               cx = endX
               cy = endY
               */
              i += 7
            case "S" =>
              /*
               val ppx = vertices[vertexCount-2][X]
               val ppy = vertices[vertexCount-2][Y]
               val px = vertices[vertexCount-1][X]
               val py = vertices[vertexCount-1][Y]
               val ctrlX1 = px + (px - ppx)
               val ctrlY1 = py + (py - ppy)
               val ctrlX2 = PApplet.parseFloat(pathDataKeys[i + 1])
               val ctrlY2 = PApplet.parseFloat(pathDataKeys[i + 2])
               val endX = PApplet.parseFloat(pathDataKeys[i + 3])
               val endY = PApplet.parseFloat(pathDataKeys[i + 4])
               parsePathCurveto(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
               cx = endX
               cy = endY
               */
              i += 5
            case "s" =>
              /*
               val ppx = vertices[vertexCount-2][X]
               val ppy = vertices[vertexCount-2][Y]
               val px = vertices[vertexCount-1][X]
               val py = vertices[vertexCount-1][Y]
               val ctrlX1 = px + (px - ppx)
               val ctrlY1 = py + (py - ppy)
               val ctrlX2 = cx + PApplet.parseFloat(pathDataKeys[i + 1])
               val ctrlY2 = cy + PApplet.parseFloat(pathDataKeys[i + 2])
               val endX = cx + PApplet.parseFloat(pathDataKeys[i + 3])
               val endY = cy + PApplet.parseFloat(pathDataKeys[i + 4])
               parsePathCurveto(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
               cx = endX
               cy = endY
               */
              i += 5
            case "Q" =>
              /*
               val ctrlX = PApplet.parseFloat(pathDataKeys[i + 1])
               val ctrlY = PApplet.parseFloat(pathDataKeys[i + 2])
               val endX = PApplet.parseFloat(pathDataKeys[i + 3])
               val endY = PApplet.parseFloat(pathDataKeys[i + 4])
               parsePathQuadto(cx, cy, ctrlX, ctrlY, endX, endY)
               cx = endX;
               cy = endY;
               */
              i += 5
            case "q" =>
              /*
               val ctrlX = cx + PApplet.parseFloat(pathDataKeys[i + 1])
               val ctrlY = cy + PApplet.parseFloat(pathDataKeys[i + 2])
               val endX = cx + PApplet.parseFloat(pathDataKeys[i + 3])
               val endY = cy + PApplet.parseFloat(pathDataKeys[i + 4])
               parsePathQuadto(cx, cy, ctrlX, ctrlY, endX, endY)
               cx = endX
               cy = endY
               */
              i += 5
            case "T" =>
              /*
               val ppx = vertices[vertexCount-2][X]
               val ppy = vertices[vertexCount-2][Y]
               val px = vertices[vertexCount-1][X]
               val py = vertices[vertexCount-1][Y]
               val ctrlX = px + (px - ppx)
               val ctrlY = py + (py - ppy)
               val endX = PApplet.parseFloat(pathDataKeys[i + 1])
               val endY = PApplet.parseFloat(pathDataKeys[i + 2])
               parsePathQuadto(cx, cy, ctrlX, ctrlY, endX, endY)
               cx = endX
               cy = endY
               */
              i += 3
            case "t" =>
              /*
               val ppx = vertices[vertexCount-2][X]
               val ppy = vertices[vertexCount-2][Y]
               val px = vertices[vertexCount-1][X]
               val py = vertices[vertexCount-1][Y]
               val ctrlX = px + (px - ppx)
               val ctrlY = py + (py - ppy)
               val endX = cx + PApplet.parseFloat(pathDataKeys[i + 1])
               val endY = cy + PApplet.parseFloat(pathDataKeys[i + 2])
               parsePathQuadto(cx, cy, ctrlX, ctrlY, endX, endY)
               cx = endX;
               cy = endY;
               */
              i += 3
            case "Z" =>
            case "z" =>
              i += 1
            case _ => i += 1
          }
        }
        println("yo")
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
