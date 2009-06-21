/*
 * render.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.render

import java.util.ArrayList

import org.villane.box2d.draw.Color3f
import org.villane.vecmath.Vector2
import org.villane.box2d.shapes.Shape
import org.villane.box2d.shapes.Polygon
import org.villane.vecmath.Transform2f
import org.villane.box2d.dynamics.World

import melee.Melee

class Render() {

    /*
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

    def update(g:Graphics, world:World) {
        transX = g.screenWidth * 0.5f;
        transY = g.screenHeight * 0.5f;
    }

	def drawPolygon(g:Graphics, shape:Shape, xf:Transform2f, color:Color3f) {

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
    
    def map(mapMe: Float, fromLow: Float, fromHigh: Float, toLow: Float, toHigh: Float) = {
        val interp = (mapMe - fromLow) / (fromHigh - fromLow)
        (interp*toHigh + (1.0f-interp)*toLow)
    }
    
    override def worldToScreen(world: Vector2) = {
        val x = map(world.x, 0f, 1f, transX, transX+scaleFactor)
        var y = map(world.y, 0f, 1f, transY, transY+scaleFactor)
        if (yFlip == -1.0f) y = map(y, 0f, container.getHeight, container.getHeight, 0f)
        Vector2(x, y)
    }

    override def screenToWorld(screen: Vector2) = {
        val x = map(screen.x, transX, transX+scaleFactor, 0f, 1f)
        var y = screen.y
        if (yFlip == -1.0f) y = map(y, container.getHeight, 0f, 0f, container.getHeight)
        y = map(y, transY, transY + scaleFactor, 0f, 1f)
        Vector2(x, y)
    }
    */
}
