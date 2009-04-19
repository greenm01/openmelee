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
package ships;

import phx.Body;
import phx.World;
import phx.Polygon;
import phx.Circle;
import phx.Properties;
import phx.Vector;

import ships.Ship;
import melee.Melee;

// Orz Nemesis
class Orz extends Ship
{
    var scale : Float;
    var offset : Vector;
    var howitzer : Body;
    var primary : GameObject;
    var turret : Body;
	var tA : Float;
	
    public function new(melee : Melee) {

        super(melee);
		tA = 0.0;
        health = 20.0;
        scale = 0.025;
        offset = Vector.init();
        engineForce = new Vector(300, 0);
        turnForce = new Vector(0, 3000);
        rightTurnPoint = new Vector(-0.5, 0);
        leftTurnPoint = new Vector(0.5, 0);

        var pos = new Vector(410.0, 360.0);
        props.maxMotion = 5e3;
        rBody = new Body(pos.x, pos.y, props);
		
        // Body
        var body = new Array();
        body[0]=(new Vector(42 * scale, 14 * scale));
        body[1]=(new Vector(42 * scale, -21 * scale));
        body[2]=(new Vector(-28 * scale, -28 * scale));
        body[3]=(new Vector(-28 * scale, 21 * scale));
        rBody.addShape(new Polygon(body, offset));
    
        // Top Wing
        var tWing = new Array();
        tWing[0]=(new Vector(-28 * scale, 21 * scale));
        tWing[1]=(new Vector(-70 * scale, 63 * scale));
        tWing[2]=(new Vector(-49 * scale, 63 * scale));
        tWing[3]=(new Vector(70 * scale, 14 * scale));
        tWing[4]=(new Vector(42 * scale, 14 * scale));
        rBody.addShape(new Polygon(tWing, offset));
        
        // Bottom Wing
        var bWing = new Array();
        bWing[0]=(new Vector(-28 * scale, -28 * scale));
        bWing[4]=(new Vector(-70 * scale, -63 * scale));
        bWing[3]=(new Vector(-49 * scale, -63 * scale));
        bWing[2]=(new Vector(70 * scale, -21 * scale));
        bWing[1]=(new Vector(42 * scale, -21 * scale));
        rBody.addShape(new Polygon(bWing, offset));
        
		// Turret
		turret = new Body(pos.x, pos.y, props);
		offset.set(0, -0.05);
		var base = new Circle(0.6, offset);
		pos = pos.plus(offset);
		var verts = new Array<Vector>();
		verts.push(new Vector(0.15,0.75));
		verts.push(new Vector(0.15,-0.5));
		verts.push(new Vector(-0.15,-0.5));
		verts.push(new Vector( -0.15, 0.75));
		offset.set(0.0, 0.5);
		var barrel = new Polygon(verts, offset);
		base.groups = barrel.groups = 2;
		turret.addShape(base);
		turret.addShape(barrel);
		
		world.addBody(turret);
        world.addBody(rBody);
      }
      
      public override function fire() {
          primary = new PrimaryWeapon(this, melee);
		  primary.group = group;
          var verts = new Array<Vector>();
          verts.push(new Vector(0.25,0.5));
          verts.push(new Vector(0.25,-0.5));
          verts.push(new Vector(-0.25,-0.5));
          verts.push(new Vector(-0.25,0.5));
          var poly = new Polygon(verts, Vector.init());
          var localPos = new Vector(0, 1.25);
          var worldPos = turret.worldPoint(localPos);
          howitzer = new Body(worldPos.x, worldPos.y);
		  howitzer.a = turret.a;
          howitzer.v = new Vector(0.0, 100.0).rotate(turret.a);
          howitzer.addShape(poly);
          world.addBody(howitzer);
          primary.rBody = howitzer;
          primary.lifetime = 2.5;
          primary.damage = 10.0;
          primary.health = 5.0;
          melee.objectList.add(primary);
      }
	  
	public override function uponDeath() {
		for (s in turret.shapes) {
			s.groups = 1;
		}
	}
	  
	public override function updateSpecial() {
	  turret.v = rBody.v;
	  turret.x = rBody.x;
	  turret.y = rBody.y;
	  if (special) {
		  if (turnL) {
			tA += Math.PI / 32;
		  } else if (turnR) {
			tA -= Math.PI / 32;
		  } else {
			// Release a marine
			var marine = new Marine(melee, this);
			marine.group = group;
			var verts = new Array<Vector>();
			verts.push(new Vector(0.0,0.25));
			verts.push(new Vector(0.15,0.0));
			verts.push(new Vector( -0.15, 0.0));
			var poly = new Polygon(verts, Vector.init());
			var localPos = new Vector(0, 1.25);
			var worldPos = turret.worldPoint(localPos);
			marine.rBody = new Body(worldPos.x, worldPos.y, props);
			marine.rBody.addShape(poly);
			world.addBody(marine.rBody);
			melee.objectList.add(marine);
		  }
	  }
	  turret.a = rBody.a + Math.PI/2 + tA;
	}
}
