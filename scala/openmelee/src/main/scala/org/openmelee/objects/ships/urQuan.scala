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
 * this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * * Neither the name of OpenMelee nor the names of its contributors may be
 * used to endorse or promote products derived from this software without specific
 * prior written permission.
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
package org.openmelee.objects.ships
 
import org.villane.box2d.dynamics.{BodyDef, World, FixtureDef}
import org.villane.box2d.shapes.{PolygonDef, CircleDef}
import org.villane.vecmath.Vector2f

import org.newdawn.slick.Graphics
import org.newdawn.slick.svg.{InkscapeLoader, SimpleDiagramRenderer}

import melee.Melee
import utils.Util

// UrQuan Dreadnought
class UrQuan(melee:Melee) extends Ship(melee) {
  
  name = new String("UrQuan: Kzer-Za")
  captain = new String("Lord 999")

  pDelay = 0.1f
  sDelay = 0.5f
  bDelay = 0.25f

  crewCapacity = 42; crew = 42
  batteryCapacity = 42; battery = 42
  pEnergy = 8
  sEnergy = 6

  val scale = 0.008f
  val offset = new Vector2f(0, 0)
  engineForce = new Vector2f(800, 0)
  turnForce = new Vector2f(0, 3000)
  rightTurnPoint = new Vector2f(-0.5f, 0)
  leftTurnPoint = new Vector2f(0.5f, 0)

  InkscapeLoader.RADIAL_TRIANGULATION_LEVEL = 2
  val renderer = new SimpleDiagramRenderer(InkscapeLoader.load("data/Kzer-Za.svg"))

  val bodyDef = new BodyDef
  bodyDef.pos = new Vector2f(10f, 10f)
  bodyDef.angle = 3.14159f/4f

  override val body = melee.world.createBody(bodyDef)

  // Bridge

  val bridge = renderer.diagram.getFigureByID("bridge")
  val bridgeVerts = Util.svgToWorld(bridge.getShape.getPoints, scale)
  val bridgeDef = PolygonDef(bridgeVerts)
  var bf = new FixtureDef(bridgeDef)
  bf.density = 5.0f
  body.createFixture(bf)

  // Body

  val shipBody = renderer.diagram.getFigureByID("body")
  val bodyVerts = Util.svgToWorld(shipBody.getShape.getPoints, scale)
  val bDef = PolygonDef(bodyVerts)
  bf = new FixtureDef(bDef)
  bf.density = 5.0f
  body.createFixture(bf)

  // Left strut

  val ls = renderer.diagram.getFigureByID("leftStrut")
  val lsVerts = Util.svgToWorld(ls.getShape.getPoints, scale)
  lsVerts.foreach(println)
  println("***************")
  Util.hull(lsVerts).foreach(println)
  val lsDef = PolygonDef(lsVerts)
  bf = new FixtureDef(lsDef)
  bf.density = 5.0f
  body.createFixture(bf)

  // Left wing

  val lw = renderer.diagram.getFigureByID("leftWing")
  val lwVerts = Util.svgToWorld(lw.getShape.getPoints, scale)
  val lwDef = PolygonDef(lwVerts)
  bf = new FixtureDef(lwDef)
  bf.density = 5.0f
  body.createFixture(bf)

  // Right strut

  val rs = renderer.diagram.getFigureByID("rightStrut")
  val rsVerts = Util.svgToWorld(rs.getShape.getPoints, scale)
  val rsDef = PolygonDef(rsVerts)
  bf = new FixtureDef(rsDef)
  bf.density = 5.0f
  body.createFixture(bf)

  // Right wing
  /*
  val rw = renderer.diagram.getFigureByID("rightWing")
  val rwVerts = Util.hull(Util.svgToWorld(rw.getShape.getPoints, scale))
  rwVerts.foreach(println)
  val rwDef = PolygonDef(rwVerts)
  bf = new FixtureDef(rwDef)
  bf.density = 5.0f
  body.createFixture(bf)

  // Tail

  val tail = renderer.diagram.getFigureByID("tail")
  val tVerts = Util.svgToWorld(tail.getShape.getPoints, scale)
  val tDef = PolygonDef(tVerts)
  bf = new FixtureDef(tDef)
  bf.density = 5.0f
  //body.createFixture(bf)
  */
 
  body.computeMassFromShapes

  def loadShape() {
    //val g = melee.asInstanceOf[PApplet]
    //sprite = g.loadShape("Kzer-Za.svg")
    //sprite.scale(0.15f)
  }

	override def fire = {
    /*
     if(!primaryTime() || battery <= pEnergy) return;
     batteryCost(pEnergy);
     primeWep = new PrimaryWeapon(this, melee);
     primeWep.group = group;
     var verts = new Array<Vector2f>();
     verts.push(new Vector2f(0.25,0.5));
     verts.push(new Vector2f(0.25,-0.5));
     verts.push(new Vector2f(-0.25,-0.5));
     verts.push(new Vector2f(-0.25,0.5));
     var poly = new Polygon(verts, Vector2f.init());
     var localPos = new Vector2f(1.5, -0.25);
     var worldPos = body.worldPoint(localPos);
     var howitzer = new Body(worldPos.x, worldPos.y);
     howitzer.a = body.a + Math.PI/2;
     howitzer.v = new Vector2f(100.0, 0.0).rotate(body.a);
     howitzer.addShape(poly);
     world.addBody(howitzer);
     primeWep.body = howitzer;
     primeWep.lifetime = 2.5;
     primeWep.damage = 10;
     primeWep.crew = 5;
     primeWep.draw(0xFF0000);
     primeWep.init();
     */
  }
    
  override def updateSpecial = {
  }

  def render(g: Graphics) {
    g.translate(250, 100)
    g.scale(0.1f,0.1f)
    g.rotate(0,0, Math.Pi.toFloat/4f*57.2957795f)
    renderer.render(g)
    g.resetTransform
  }
 
} 