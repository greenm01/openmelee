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
import org.villane.box2d.shapes.PolygonDef
import org.villane.box2d.shapes.CircleDef
import org.villane.vecmath.Vector2f

import openmelee.melee.Melee;

// Orz Nemesis
class Orz(melee:Melee) extends Ship(melee)
{

    private var scale : Float = _
    private var offset : Vector2f = _
	private var tA : Float = _

    name = new String("Orz: Nemesis")
    captain = new String("zzzzrrr")

    tA = 0.0f
    pDelay = 0.15f
    sDelay = 0.5f
    bDelay = 0.25f
    crewCapacity = 16
    crew = 16
    batteryCapacity = 20
    battery = 20
    pEnergy = 5
    sEnergy = 6

    scale = 0.025f
    engineForce = new Vector2f(1000f, 0f)
    turnForce = new Vector2f(0f, 5000f)
    rightTurnPoint = new Vector2f(-0.5f, 0f)
    leftTurnPoint = new Vector2f(0.5f, 0f)

    val bodyDef = new BodyDef
    bodyDef.pos = new Vector2f(-10f, 10f)
    bodyDef.angle = 3.14159f/4f
    body = melee.world.createBody(bodyDef)
    var linVel = new Vector2f(10f,0f)
    //body.linearVelocity = linVel

    // Body
    val pd = new PolygonDef
    pd.density = 5.0f
    pd.vertices = Array( point(42, 14),
                         point(-28, 21),
                         point(-28, -28),
                         point(42, -21))
    body.createShape(pd)

    // Top Wing
    var tWing = new PolygonDef
    tWing.density = 5.0f
    tWing.vertices = Array(point(-28, 21),
                           point(42, 14),
                           point(70, 14),
                           point(-49, 63),
                           point(-70, 63))
    body.createShape(tWing)

    // Bottom Wing
    var bWing = new PolygonDef
    bWing.density = 5f
    bWing.vertices = Array(point(-28, -28),
                           point(-70, -63),
                           point(-49, -63),
                           point(70, -21),
                           point(42, -21))
    body.createShape(bWing)
   
    body.computeMassFromShapes
    
    /*
    // Turret
    secondWep = new SecondaryWeapon(this, melee);
    secondWep.group = group;
    secondWep.rBody = new Body(pos.x, pos.y, props);
    offset.set(0, -0.05);
    var base = new Circle(0.6, offset);
    var verts = new Array<Vector2f>();
    verts.push(new Vector2f(0.15,0.75));
    verts.push(new Vector2f(0.15,-0.5));
    verts.push(new Vector2f(-0.15,-0.5));
    verts.push(new Vector2f( -0.15, 0.75));
    offset.set(0.0, 0.5);
    var barrel = new Polygon(verts, offset);
    base.groups = barrel.groups = 2;
    secondWep.rBody.addShape(base);
    secondWep.rBody.addShape(barrel);
    secondWep.init();
    */

    def point(x:Float, y:Float) = {
        val p = new Vector2f(x*scale,y*scale)
        p
    }

	override def fire = {
        /*
		if (!primaryTime() || battery < pEnergy) return;
			batteryCost(pEnergy);
			primeWep = new PrimaryWeapon(this, melee);
		  	primeWep.group = group;
          	var verts = new Array<Vector2f>();
          	verts.push(new Vector2f(0.25,0.5));
          	verts.push(new Vector2f(0.25,-0.5));
          	verts.push(new Vector2f(-0.25,-0.5));
          	verts.push(new Vector2f(-0.25,0.5));
          	var poly = new Polygon(verts, Vector2f.init());
          	var localPos = new Vector2f(0, 1.25);
          	var worldPos = secondWep.rBody.worldPoint(localPos);
          	howitzer = new Body(worldPos.x, worldPos.y);
		  	howitzer.a = secondWep.rBody.a;
          	howitzer.v = new Vector2f(0.0, 100.0).rotate(howitzer.a);
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
			tA += Math.PI / 32;
		  } else if (turnR) {
			tA -= Math.PI / 32;
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
		turret.a = rBody.a + Math.PI/2 + tA;
        */
	}
}

