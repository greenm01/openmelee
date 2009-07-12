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
package org.openmelee.melee

import collection.jcl.ArrayList

import org.villane.box2d.shapes.{AABB, Polygon, Circle}
import org.villane.box2d.dynamics.World
import org.villane.box2d.draw.{DebugDraw, Color3f}
import org.villane.vecmath.Vector2

import org.newdawn.slick.state.{BasicGameState, StateBasedGame}
import org.newdawn.slick.{GameContainer, Color, Graphics}

import render.SlickDebugDraw
import objects.{GameObject, Filter}
import objects.ships.{Orz, UrQuan}

import ai.Human
import utils.svg.SVG
import utils.geo.{Triangulator, Segment, Trapezoid}

class Melee(stateID:Int) extends BasicGameState {

  println("OpenMelee 0.1")
  
  var tesselator: Triangulator = null
  
  val debugDraw = new SlickDebugDraw(null,null)
  
  val objectList = new ArrayList[GameObject]

  val min = new Vector2(-200f, -100f)
  val max = new Vector2(200f, 200f)
  val worldAABB = new AABB(min, max)
  val gravity = new Vector2(0f, 0f)
  val world = new World(worldAABB, gravity, false)

  val filter = new Filter
  world.contactFilter = filter
  
  val orz = new Orz(this)
  objectList += orz
  val kz = new UrQuan(this)
  objectList += kz
  
  val human = new Human(kz)
  val timeStep = 1f/60f
  val iterations = 10

  override def getID = stateID

  var debug = false
  var drawSVG = false

  val svg = new SVG("data/test.svg")
  
  var testTrap: Trapezoid = null
  
  testTesselator
  
  override def init(gc: GameContainer, sb:StateBasedGame) {
    debugDraw.g = gc.getGraphics
    debugDraw.container = gc
  }

  override def update(gc: GameContainer, sb:StateBasedGame, delta:Int) {
    if(human.quit) gc.exit()
    objectList.foreach(o => o.updateState)
    world.step(timeStep, iterations)
  }

  override def render(gc: GameContainer, sb:StateBasedGame, g: Graphics) {

    if(drawSVG) {
      kz.render(g)
      orz.render(g)
    }

    if(debug) {
      val red = new Color3f(255.0f,0.0f,0.0f,255)
      for(b <- world.bodyList) {
        for(f <- b.fixtures) {
          f.shape match {
            case poly: Polygon =>
              val p = f.shape.asInstanceOf[Polygon]
              val vertexCount = p.vertices.length
              val wVerts = Array.fromFunction(p.vertices)(vertexCount)
              for(i <- 0 until vertexCount) {
                wVerts(i) = b.transform*p.vertices(i)
              }
              debugDraw.drawPolygon(wVerts, red)
            case circle: Circle =>
              val center = b.transform * circle.pos
              val radius = circle.radius
              val axis = b.transform.rot.col1
              debugDraw.drawCircle(center, radius, red)
          }
        }
      }
    }

    if(drawSVG) svg.render
    
    val red = new Color3f(255.0f,0.0f,0.0f,255)
    val blue = new Color3f(0f, 0f, 255f, 255)
    val green = new Color3f(0f, 255f, 0f ,255)
    
   //for(t <- tesselator.allTrapezoids) {
   //for(t <- tesselator.trapezoids) {
	  //debugDraw.drawPolygon(t.vertices, red)
	  //debugDraw.drawPoint(t.leftPoint, 0f, green)
	  //debugDraw.drawPoint(t.rightPoint, 0f, green)
    //}
   
    for(x <- tesselator.xMonoPoly) {
      val p = new Array[Vector2](x.size)
      assert(p.size > 2)
      var i = 0
      for(t <- x) { p(i)= t; i += 1}
      debugDraw.drawPolygon(p, green)
    }

  }

  override def keyPressed(key:Int, c:Char) {
    if(c == 'b') drawSVG = !drawSVG
    if(key == 57) debug = !debug
    human.onKeyDown(key)
  }
  
  override def keyReleased(key:Int, c:Char) = human.onKeyUp(key)

  def testTesselator {
   
    val scale = 0.025f
    val segments = new ArrayList[Segment]
    segments += new Segment(Vector2(100,300)*scale, Vector2(400,500)*scale)
    segments += new Segment(Vector2(250,200)*scale, Vector2(600,175)*scale)
    segments += new Segment(Vector2(100,300)*scale, Vector2(250,200)*scale)
    segments += new Segment(Vector2(400,300)*scale, Vector2(400,500)*scale)
    segments += new Segment(Vector2(400,300)*scale, Vector2(650,200)*scale)
    segments += new Segment(Vector2(600,175)*scale, Vector2(650,200)*scale) 
    tesselator = new Triangulator(segments)
    tesselator.process
   }    
}