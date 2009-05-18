/*
 * render.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.render

import java.util.ArrayList

import org.villane.box2d.draw.Color3f
import org.villane.vecmath.Vector2f
import org.villane.box2d.shapes.Shape
import org.villane.box2d.shapes.Polygon
import org.villane.vecmath.Transform2f
import org.villane.box2d.dynamics.World

import processing.core.PApplet

import melee.Melee

class Render(g:PApplet) {

    // World 0,0 maps to transX, transY on screen
    var transX = 0f;
    var transY = 0f;
    var scaleFactor = 15.0f;
    val yFlip = -1.0f; //flip y coordinate

    def setCamera(x:Float, y:Float, scale:Float) {
    	transX = PApplet.map(x,0.0f,-1.0f,g.width*.5f,g.width*.5f+scale);
    	transY = PApplet.map(y,0.0f,yFlip*1.0f,g.height*0.5f,g.height*0.5f+scale);
    	scaleFactor = scale;
    }

    def update(world:World) {
        transX = g.width * 0.5f;
        transY = g.height * 0.5f;
        val color = new Color3f(1,1,0)
        for(b <- world.bodyList) {
            for(s <- b.shapes) {
                s match {
                    case poly => drawPolygon(s, b.transform, color)
                }
            }
        }
    }

	def drawPolygon(shape:Shape, xf:Transform2f, color:Color3f) {

        val poly = shape.asInstanceOf[Polygon]
        val vertices = poly.vertices

		g.stroke(color.r, color.g, color.b)
		g.noFill();
        val vertexCount = vertices.length

		for(i <- 0 until vertexCount) {
			val ind = if(i+1<vertexCount) i+1 else (i+1-vertexCount)
			val v1 = worldToScreen(xf*vertices(i))
			val v2 = worldToScreen(xf*vertices(ind))
			g.line(v1.x, v1.y, v2.x, v2.y)
        }
	}

    def drawCircle() = {}
    
    def worldToScreen(world:Vector2f) = {
		val x = PApplet.map(world.x, 0f, 1f, transX, transX+scaleFactor)
		var y = PApplet.map(world.y, 0f, 1f, transY, transY+scaleFactor)
		if (yFlip == -1.0f) y = PApplet.map(y,0f,g.height, g.height,0f)
		val v = new Vector2f(x, y)
        v
	}
}
