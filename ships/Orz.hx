/*
 * Copyright (c) 2009, Mason Green
 * http://github.com/zzzzrrr/haxmel
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
 * * Neither the name of the polygonal nor the names of its contributors may be
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

import physics.Body;
import physics.Space;
import physics.Polygon;
import utils.Vec2;
import ships.Ship;

// UrQuan Dreadnought
class Orz extends Ship
{
    var scale : Float;
    var offset : Vec2;

    public function new(space : Space) {

        scale = 0.025;
        offset = new Vec2(0, 0);
        super(space);
        engineForce = new Vec2(500, 0);
        turnForce = new Vec2(0, 5000);
        rightTurnPoint = new Vec2(0.5, 0);
        leftTurnPoint = new Vec2(-0.5, 0);

        var pos = new Vec2(25.0, 5.0);
        var angle = 0.0;

        rBody = new Body(pos, angle);

        var density = 5.0;

        // Body
        var body = new Array();
        body[0]=(new Vec2(42 * scale, 14 * scale));
        body[3]=(new Vec2(42 * scale, -21 * scale));
        body[2]=(new Vec2(-28 * scale, -28 * scale));
        body[1]=(new Vec2(-28 * scale, 21 * scale));
        rBody.addShape(new Polygon(body, offset, density));

        // Top Wing
        var tWing = new Array();
        tWing[4]=(new Vec2(-28 * scale, 21 * scale));
        tWing[3]=(new Vec2(-70 * scale, 63 * scale));
        tWing[2]=(new Vec2(-49 * scale, 63 * scale));
        tWing[1]=(new Vec2(70 * scale, 14 * scale));
        tWing[0]=(new Vec2(42 * scale, 14 * scale));
        rBody.addShape(new Polygon(tWing, offset, density));

        // Bottom Wing
        var bWing = new Array();
        bWing[0]=(new Vec2(-28 * scale, -28 * scale));
        bWing[1]=(new Vec2(-70 * scale, -63 * scale));
        bWing[2]=(new Vec2(-49 * scale, -63 * scale));
        bWing[3]=(new Vec2(70 * scale, -21 * scale));
        bWing[4]=(new Vec2(42 * scale, -21 * scale));
        rBody.addShape(new Polygon(bWing, offset, density));

        rBody.setMassFromShapes();
        space.addBody(rBody);
        //setPlanetGravity();
      }
}
