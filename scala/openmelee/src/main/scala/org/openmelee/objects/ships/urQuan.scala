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
  engineForce = new Vector2f(0, -10)
  turnForce = new Vector2f(0, 3000)
  rightTurnPoint = new Vector2f(-0.5f, 0)
  leftTurnPoint = new Vector2f(0.5f, 0)

  InkscapeLoader.RADIAL_TRIANGULATION_LEVEL = 2
  val renderer = new SimpleDiagramRenderer(InkscapeLoader.load("data/Kzer-Za.svg"))

  val bodyDef = new BodyDef
  bodyDef.pos = new Vector2f(10f, 10f)

  override val body = melee.world.createBody(bodyDef)

  val parts = Array("bridge", "body", "leftStrut", "leftWing", "rightStrut",
                    "rightWing", "tail")

  for(p <- parts) {
    val partID = renderer.diagram.getFigureByID(p)
    val verts = Util.hull(Util.svgToWorld(partID.getShape.getPoints, scale))
    val fd = new FixtureDef(PolygonDef(verts))
    fd.density = 5.0f
    body.createFixture(fd)
  }

  body.computeMassFromShapes

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
    val pos = melee.debugDraw.worldToScreen(body.pos)
    g.translate(pos.x, pos.y)
    g.scale(0.095f, 0.095f)
    g.rotate(0, 0, -(body.angle+Math.Pi.toFloat)*57.2957795f)
    renderer.render(g)
    g.resetTransform
  }
 
} 