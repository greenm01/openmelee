/*
 * path.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.svg.shapes

import collection.jcl.ArrayList

import org.villane.vecmath.Vector2

class Path(pathData: Array[String]) extends Shape {

  val commands = new ArrayList[Char]
  val vertices = new ArrayList[Vector2]
  var cx, cy = 0f
  
  def parse = {
    var i = 0
    while(i < pathData.length) {
      pathData(i) match {
        case "M" =>  // M - move to (absolute)
          cx = pathData(i + 1).toFloat
          cy = pathData(i + 2).toFloat
          moveTo(cx, cy)
          i += 3
        case "m" =>  // m - move to (relative)
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
  }

  def moveTo(x: Float, y: Float) {
    // Move to vertex
    commands += 'v'
    vertices += Vector2(x, y)
  }

  def curveTo(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
    // draw BEZIER CURVE
    commands += 'b'
    vertices += Vector2(x1, y1)
    vertices += Vector2(x2, y2)
    vertices += Vector2(x3, y3)
  }

  def render() {

  }

}
