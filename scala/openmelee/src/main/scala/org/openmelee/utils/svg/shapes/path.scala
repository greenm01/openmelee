/*
 * path.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.svg.shapes

import collection.jcl.ArrayList

import org.villane.vecmath.Vector2

/* NOTE: Elliptical arc curves are supported in SVG 1.1, and excluded
 * in SVG 1.2. They will be included here for legacy purposes
 */
class Path(pathData: Array[String]) extends Shape {

  object Commands extends Enumeration {
    val VERTEX, BEZIER_CURVE, ARC = Value
  }

  val commands = new ArrayList[Commands.Value]
  val vertices = new ArrayList[Vector2]
  var cx, cy = 0f

  def parse = {
    var i = 0
    while(i < pathData.length) {
      val vertexCount = vertices.length
      pathData(i) match {
        case "M" =>  
          cx = pathData(i + 1).toFloat
          cy = pathData(i + 2).toFloat
          moveTo(cx, cy)
          i += 3
        case "m" =>  
          cx = cx + pathData(i + 1).toFloat
          cy = cy + pathData(i + 1).toFloat
          moveTo(cx, cy)
          i += 3
        case "L" =>
          cx = pathData(i + 1).toFloat
          cy = pathData(i + 2).toFloat
          moveTo(cx, cy)
          i += 3
        case "l" =>
          cx = cx + pathData(i + 1).toFloat
          cy = cy + pathData(i + 1).toFloat
          moveTo(cx, cy)
          i += 3
        case "H" =>
          cx = pathData(i + 1).toFloat
          moveTo(cx, cy)
          i += 2
        case "h" =>
          cx = cx + pathData(i + 1).toFloat
          moveTo(cx, cy)
          i += 2
        case "V" =>
          cy = pathData(i + 1).toFloat
          moveTo(cx, cy)
          i += 2
        case "v" =>
          cy = cy + pathData(i + 1).toFloat
          moveTo(cx, cy)
          i += 2
        case "C" =>
          val ctrlX1 = pathData(i + 1).toFloat
          val ctrlY1 = pathData(i + 2).toFloat
          val ctrlX2 = pathData(i + 3).toFloat
          val ctrlY2 = pathData(i + 4).toFloat
          val endX = pathData(i + 5).toFloat
          val endY = pathData(i + 6).toFloat
          curveTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
          cx = endX
          cy = endY
          i += 7
        case "c" =>
          val ctrlX1 = cx + pathData(i + 1).toFloat
          val ctrlY1 = cy + pathData(i + 2).toFloat
          val ctrlX2 = cx + pathData(i + 3).toFloat
          val ctrlY2 = cy + pathData(i + 4).toFloat
          val endX = cx + pathData(i + 5).toFloat
          val endY = cy + pathData(i + 6).toFloat
          curveTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
          cx = endX
          cy = endY
          i += 7
        case "S" =>
          val ppx = vertices(vertexCount-2).x
          val ppy = vertices(vertexCount-2).y
          val px = vertices(vertexCount-1).x
          val py = vertices(vertexCount-1).y
          val ctrlX1 = px + (px - ppx)
          val ctrlY1 = py + (py - ppy)
          val ctrlX2 = pathData(i + 1).toFloat
          val ctrlY2 = pathData(i + 2).toFloat
          val endX = pathData(i + 3).toFloat
          val endY = pathData(i + 4).toFloat
          curveTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
          cx = endX
          cy = endY
          i += 5
        case "s" =>
          val ppx = vertices(vertexCount-2).x
          val ppy = vertices(vertexCount-2).y
          val px = vertices(vertexCount-1).x
          val py = vertices(vertexCount-1).y
          val ctrlX1 = px + (px - ppx)
          val ctrlY1 = py + (py - ppy)
          val ctrlX2 = cx + pathData(i + 1).toFloat
          val ctrlY2 = cy + pathData(i + 2).toFloat
          val endX = cx + pathData(i + 3).toFloat
          val endY = cy + pathData(i + 4).toFloat
          curveTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY)
          cx = endX
          cy = endY
          i += 5
        case "Q" =>
          val ctrlX = pathData(i + 1).toFloat
          val ctrlY = pathData(i + 2).toFloat
          val endX = pathData(i + 3).toFloat
          val endY = pathData(i + 4).toFloat
          quadTo(cx, cy, ctrlX, ctrlY, endX, endY)
          cx = endX;
          cy = endY;
          i += 5
        case "q" =>
          val ctrlX = cx + pathData(i + 1).toFloat
          val ctrlY = cy + pathData(i + 2).toFloat
          val endX = cx + pathData(i + 3).toFloat
          val endY = cy + pathData(i + 4).toFloat
          quadTo(cx, cy, ctrlX, ctrlY, endX, endY)
          cx = endX
          cy = endY
          i += 5
        case "T" =>
          val ppx = vertices(vertexCount-2).x
          val ppy = vertices(vertexCount-2).y
          val px = vertices(vertexCount-1).x
          val py = vertices(vertexCount-1).y
          val ctrlX = px + (px - ppx)
          val ctrlY = py + (py - ppy)
          val endX = pathData(i + 1).toFloat
          val endY = pathData(i + 2).toFloat
          quadTo(cx, cy, ctrlX, ctrlY, endX, endY)
          cx = endX
          cy = endY
          i += 3
        case "t" =>
          val ppx = vertices(vertexCount-2).x
          val ppy = vertices(vertexCount-2).y
          val px = vertices(vertexCount-1).x
          val py = vertices(vertexCount-1).y
          val ctrlX = px + (px - ppx)
          val ctrlY = py + (py - ppy)
          val endX = cx + pathData(i + 1).toFloat
          val endY = cy + pathData(i + 2).toFloat
          quadTo(cx, cy, ctrlX, ctrlY, endX, endY)
          cx = endX;
          cy = endY;
          i += 3
        case "A" =>
          // Elicptical arc (absolute)
          val rx = pathData(i + 1).toFloat
          val ry = pathData(i + 2).toFloat
          val xRot = pathData(i + 3).toFloat
          val largeArc = pathData(i + 4).toInt
          val sweep = pathData(i + 5).toInt
          val x = pathData(i + 6).toFloat
          val y = pathData(i + 7).toFloat
          arcTo(rx, ry, xRot, largeArc, sweep, x, y)
          cx = x
          cy = y
          i += 8
        case "a" =>
          // Elicptical arc (relative)
          val rx = pathData(i + 1).toFloat
          val ry = pathData(i + 2).toFloat
          val xRot = pathData(i + 3).toFloat
          val largeArc = pathData(i + 4).toInt
          val sweep = pathData(i + 5).toInt
          val x = cx + pathData(i + 6).toFloat
          val y = cy + pathData(i + 7).toFloat
          arcTo(rx, ry, xRot, largeArc, sweep, x, y)
          cx = x
          cy = y
          i += 8
        case "Z" =>
        case "z" =>
          i += 1
        case _ =>
          i += 1
      }
    }
  }

  def moveTo(x: Float, y: Float) {
    commands += Commands.VERTEX
    vertices += Vector2(x, y)
  }

  def curveTo(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
    commands += Commands.BEZIER_CURVE
    vertices += Vector2(x1, y1)
    vertices += Vector2(x2, y2)
    vertices += Vector2(x3, y3)
  }

  def quadTo(x1: Float, y1: Float, cx: Float, cy: Float, x2: Float, y2: Float) {
    commands += Commands.BEZIER_CURVE
    vertices += Vector2(x1 + ((cx-x1)*2/3.0f), y1 + ((cy-y1)*2/3.0f));
    vertices += Vector2(x2 + ((cx-x2)*2/3.0f), y2 + ((cy-y2)*2/3.0f));
    vertices += Vector2(x2, y2);
  }

  def arcTo(rx: Float, ry: Float, xRot: Float, largeArc: Int, sweep: Int, x: Float, y: Float) {
    // TODO: Enable xRot
    commands += Commands.ARC
    vertices += Vector2(rx, ry)
    vertices += Vector2(cx, cy)
    vertices += Vector2(x ,y)
    vertices += Vector2(largeArc, sweep)
  }

  def render() {

  }

}
