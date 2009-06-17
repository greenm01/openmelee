/*
 * Melee.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.melee

import collection.jcl.ArrayList

import org.villane.box2d.shapes.{AABB, Polygon}
import org.villane.box2d.dynamics.World
import org.villane.box2d.draw.{DebugDraw, Color3f}
import org.villane.vecmath.Vector2f

import org.newdawn.slick.state.{BasicGameState, StateBasedGame}
import org.newdawn.slick.{GameContainer, Color, Graphics}

import render.{Render, SlickDebugDraw}
import objects.GameObject
import objects.ships.{Orz, UrQuan}

import ai.Human

class Melee(stateID:Int) extends BasicGameState {

  val debugDraw = new SlickDebugDraw(null,null)

  val objectList = new ArrayList[GameObject]

  val min = new Vector2f(-200f, -100f)
	val max = new Vector2f(200f, 200f)
	val worldAABB = new AABB(min, max)
	val gravity = new Vector2f(0f, 0f)
	val world = new World(worldAABB, gravity, false)
    
  val orz = new Orz(this)
  val kz = new UrQuan(this)
  
  objectList += orz

  val human = new Human(orz)
  val timeStep = 1f/60f
  val iterations = 10

  override def getID = stateID

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

    kz.render(g)
    
    val red = new Color3f(255.0f,0.0f,0.0f)
        
    for(b <- world.bodyList) {
      for(f <- b.fixtures) {
        f.shape match {
          case poly =>
            val p = f.shape.asInstanceOf[Polygon]
            val vertexCount = p.vertices.length
            val wVerts = Array.fromFunction(p.vertices)(vertexCount)
            for(i <- 0 until vertexCount) {
              wVerts(i) = b.transform*p.vertices(i)
            }
            debugDraw.drawPolygon(wVerts, red)
        }
      }
    }
  }

  override def keyPressed(key:Int, c:Char) = human.onKeyDown(key)
  override def keyReleased(key:Int, c:Char) = human.onKeyUp(key)


  /*
   override def setup() {
   kz.loadShape
   width = 640
   height = 480
   val targetFPS = 60
   size(width, height, PConstants.P3D)
   frameRate(targetFPS)
   for (i <- 0 until 100) {
   requestFocus
   }
   frame.setTitle("OpenMelee")
   }

   // Main processing loop
   override def draw() {
        
   kz.sprite.rotate(0.01f)
   background(0xFAF0E6)
   shape(kz.sprite, 320, 240)

   for(o <- objectList)
   o.updateState()

   world.step(timeStep, iterations)
   render update world
   }

   override def keyPressed() {
   human.onKeyDown(keyCode)
   }

   override def keyReleased() {
   human.onKeyUp(keyCode)
   }
   */
    
}