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
package org.openmelee.objects.ships

import org.villane.box2d.dynamics.BodyDef
import org.villane.box2d.dynamics.World
import org.villane.box2d.shapes.{PolygonDef, Polygon}
import org.villane.box2d.shapes.CircleDef
import org.villane.box2d.dynamics.FixtureDef

import org.newdawn.slick.Graphics
import org.newdawn.slick.svg.{InkscapeLoader, SimpleDiagramRenderer}
import org.newdawn.slick.geom.Circle

import org.villane.vecmath.Vector2

import melee.Melee;
import utils.Util
import utils.svg.SVGParser

// Orz Nemesis
class Orz(melee:Melee) extends Ship(melee) {

  private var scale : Float = _
  private var offset : Vector2 = _

  name = new String("Orz: Nemesis")
  captain = new String("zzzzrrr")

  InkscapeLoader.RADIAL_TRIANGULATION_LEVEL = 2
  // Main body's skeleton'
  val skeleton = new SimpleDiagramRenderer(InkscapeLoader.load("data/Nemesis.svg"))
  // Turret skeleton
  val tSkeleton = new SimpleDiagramRenderer(InkscapeLoader.load("data/test2.svg"))

  val p = new SVGParser("data/test.svg")
  p.parse
  
  private var turretAngle = 0.0f
  pDelay = 0.15f
  sDelay = 0.5f
  bDelay = 0.25f
  crewCapacity = 16
  crew = 16
  batteryCapacity = 20
  battery = 20
  pEnergy = 5
  sEnergy = 6

  scale = 0.0062f
  engineForce = new Vector2(10f, 0f)
  turnForce = new Vector2(0f, 500f)
  rightTurnPoint = new Vector2(-0.5f, 0f)
  leftTurnPoint = new Vector2(0.5f, 0f)

  val bodyDef = new BodyDef
  bodyDef.pos = new Vector2(0f, 0f)
  bodyDef.angle = 3.14159f/4f
  var centroid = Vector2.Zero

  //val loadnode = xml.XML.loadFile("data/test.svg")

  override val body = melee.world.createBody(bodyDef)
  var parts = Array("B1", "B2", "B3", "R1", "R2", "R3", "R4", "R5",
                    "L1", "L2", "L3", "L4", "L5")

  for(p <- parts) {
    val partID = skeleton.diagram.getFigureByID(p)
    val verts = Util.hull(Util.svgToWorld(partID.getShape.getPoints, scale))
    val fd = new FixtureDef(PolygonDef(verts))
    fd.density = 0.5f
    val f = body.createFixture(fd)
    if(p == "B1") {
      val b = f.shape.asInstanceOf[Polygon]
      centroid = b.centroid
    }
  }
   
  body.computeMassFromShapes

  /*
  val turret = melee.world.createBody(bodyDef)
  parts = Array("barrel", "lBase", "rBase")

  for(p <- parts) {
    val partID = tSkeleton.diagram.getFigureByID(p)
    val verts = Util.hull(Util.svgToWorld(partID.getShape.getPoints, scale))
    val fd = new FixtureDef(PolygonDef(verts))
    fd.density = 0.5f
    body.createFixture(fd)
  }

  val fd = new FixtureDef(CircleDef(centroid, 180f*scale))
  fd.density = 0.5f
  body.createFixture(fd)
  */

  /*
  val foo = tSkeleton.diagram.getFigureByID("bridge")
  var circle = foo.getShape.asInstanceOf[Circle]
  println(circle.radius)
  */
  
  //turret.computeMassFromShapes

  // TODO: connect turret and body via joint
 
  def point(x:Float, y:Float) = {
    val p = new Vector2(x*scale,y*scale)
    p
  }

	override def fire = {
    /*
     if (!primaryTime() || battery < pEnergy) return;
     batteryCost(pEnergy);
     primeWep = new PrimaryWeapon(this, melee);
     primeWep.group = group;
     var verts = new Array<Vector2>();
     verts.push(new Vector2(0.25,0.5));
     verts.push(new Vector2(0.25,-0.5));
     verts.push(new Vector2(-0.25,-0.5));
     verts.push(new Vector2(-0.25,0.5));
     var poly = new Polygon(verts, Vector2.init());
     var localPos = new Vector2(0, 1.25);
     var worldPos = secondWep.rBody.worldPoint(localPos);
     howitzer = new Body(worldPos.x, worldPos.y);
     howitzer.a = secondWep.rBody.a;
     howitzer.v = new Vector2(0.0, 100.0).rotate(howitzer.a);
     howitzer.addShape(poly);
     world.addBody(howitzer);
     primeWep.rBody = howitzer;
     primeWep.lifetime = 2.5;
     primeWep.damage = 10;
     primeWep.crew = 5;
     primeWep.draw(0xFF0000);
     primeWep.init();
     */
  }

	// Collide with own objects -> collect marines
	def collect(o:GameObject) {
    /*
     if(o != primeWep) {
     crew++;
     melee.destroyList.set(o.rBody);
     }
     */
	}

	override def updateSpecial = {
    /*
     var turret = secondWep.rBody;
     turret.v = rBody.v;
     turret.x = rBody.x;
     turret.y = rBody.y;
     if (special) {
     if (turnL) {
     turretAngle += Math.PI / 32;
     } else if (turnR) {
     turretAngle -= Math.PI / 32;
     } else if (primary && crew > 1) {
     var time = flash.Lib.getTimer() * 0.001;
     var dt = time - sTime;
     if(dt >= sDelay) {
     sTime = time;
     // Release a marine
     batteryCost(sEnergy);
     crew--;
     var marine = new Marine(melee, this);
     numMarines++;
     marine.initAI(melee.ship2);
     marines.map(marine);
     }
     }
     }
     turret.a = rBody.a + Math.PI/2 + turretAngle;
     */
	}

  def render(g: Graphics) {
    val pos = melee.debugDraw.worldToScreen(body.pos)
    g.translate(pos.x, pos.y)
    g.scale(0.075f, 0.075f)
    g.rotate(0, 0, -(body.angle+Math.Pi.toFloat)*57.2957795f)
    skeleton.render(g)
    g.resetTransform
    //renderTurret(g)
  }

  def renderTurret(g: Graphics) {
    val pos = melee.debugDraw.worldToScreen(body.pos)
    g.translate(pos.x, pos.y)
    g.scale(0.075f, 0.075f)
    g.rotate(0, 0, -(body.angle+Math.Pi.toFloat)*57.2957795f)
    tSkeleton.render(g)
    g.resetTransform
  }
  
}

