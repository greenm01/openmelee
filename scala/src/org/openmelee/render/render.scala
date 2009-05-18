/*
 * render.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.render

import java.util.ArrayList

import org.jbox2d.common.Color3f
import org.jbox2d.common.Vec2
import org.jbox2d.collision.ShapeType
import org.jbox2d.collision.Shape
import org.jbox2d.collision.PolygonShape
import org.jbox2d.common.XForm

import processing.core._

import org.openmelee.melee.Melee

class Render(w:Int, h:Int, m:Melee) extends PApplet {

    width = w
    height = h
    val melee = m
    // World 0,0 maps to transX, transY on screen
    var transX = 320.0f;
    var transY = 240.0f;
    var scaleFactor = 20.0f;
    val yFlip = -1.0f; //flip y coordinate

    val timeStep = 1f/60f
    val iterations = 10
    
    def setCamera(x:Float, y:Float, scale:Float) {
    	transX = PApplet.map(x,0.0f,-1.0f,width*.5f,width*.5f+scale);
    	transY = PApplet.map(y,0.0f,yFlip*1.0f,height*0.5f,height*0.5f+scale);
    	scaleFactor = scale;
    }

    override def setup() = {
		val targetFPS = 60
		size(w, h, PConstants.P3D)
		frameRate(targetFPS)
	}

	override def draw() = {
		background(0xFAF0E6)
        melee.world.step(timeStep, iterations)
        update
	}

    private def update() = {
        val color = new Color3f(1,1,0)
        var b = melee.world.getBodyList
        while(b != null) {
            var s = b.getShapeList
            while(s != null) {
                s.getType match {
                    case ShapeType.POLYGON_SHAPE => drawPolygon(s, b.getXForm, color)
                }
                s = s.getNext
            }
            b = b.getNext
        }

    }

	def drawPolygon(shape:Shape, xf:XForm, color:Color3f) : Unit = {

        val poly = shape.asInstanceOf[PolygonShape]
        val vertices = poly.getVertices

		stroke(color.x, color.y, color.z);
		noFill();
        val vertexCount = vertices.length

		for(i <- 0 until vertexCount) {
			val ind = if(i+1<vertexCount) i+1 else (i+1-vertexCount)
			val v1 = worldToScreen(XForm.mul(xf, vertices(i)))
			val v2 = worldToScreen(XForm.mul(xf, vertices(ind)))
			line(v1.x, v1.y, v2.x, v2.y)
        }
	}

    def drawCircle() = {}
    
    def worldToScreen(world:Vec2) = {
		val x = PApplet.map(world.x, 0f, 1f, transX, transX+scaleFactor)
		var y = PApplet.map(world.y, 0f, 1f, transY, transY+scaleFactor)
		if (yFlip == -1.0f) y = PApplet.map(y,0f,g.height, g.height,0f)
		val v = new Vec2(x, y)
        v
	}


}
