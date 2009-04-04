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

import phx.Body;
import phx.World;
import phx.Polygon;
import phx.Vector;

import ships.Ship;

// UrQuan Dreadnought
class UrQuan extends Ship
{

    var scale : Float;
    var offset : Vector;
    
    public function new(world : World) {

        scale = 0.025;
        offset = new Vector(0, 0);
        super(world);
        engineForce = new Vector(500, 0);
        turnForce = new Vector(0, 9000);
        rightTurnPoint = new Vector(-0.5, 0);
        leftTurnPoint = new Vector(0.5, 0);
        
        rBody = new Body(30, 5);
        
        // Head
        var head = new Array();
        head.push(new Vector(42 * scale, 49 * scale));
        head.push(new Vector(63 * scale, 49 * scale));
        head.push(new Vector(70 * scale, 45.5 * scale));
        head.push(new Vector(73.5 * scale, 38.5 * scale));
        head.push(new Vector(73.5 * scale, -42 * scale));
        head.push(new Vector(70 * scale, -49 * scale));
        head.push(new Vector(63 * scale, -56 * scale));
        head.push(new Vector(42 * scale, -56 * scale));
        rBody.addShape(new Polygon(head, offset));
        
        // Body
        var body = new Array();
        body.push(new Vector(-70 * scale, -28 * scale));
        body.push(new Vector(-70 * scale, 24.5 * scale));
        body.push(new Vector(42 * scale, 24.5 * scale));
        body.push(new Vector(42 * scale, -31.5 * scale));
        rBody.addShape(new Polygon(body, offset));
        
        // Top Strut
        var tStrut = new Array();
        tStrut.push(new Vector(0 * scale, 24.5 * scale));
        tStrut.push(new Vector(-28 * scale, 24.5 * scale));
        tStrut.push(new Vector(-28 * scale, 42 * scale));
        tStrut.push(new Vector(0 * scale, 42 * scale));
        rBody.addShape(new Polygon(tStrut, offset));
        
        // Top Wing
        var tWing = new Array();
        tWing.push(new Vector(-70 * scale, 42 * scale));
        tWing.push(new Vector(-49 * scale, 63 * scale));
        tWing.push(new Vector(28 * scale, 63 * scale));
        tWing.push(new Vector(28 * scale, 42 * scale));
        rBody.addShape(new Polygon(tWing, offset));
        
        // Bottom Strut
        var bStrut = new Array();
        bStrut.push(new Vector(0 * scale, -31.5 * scale));
        bStrut.push(new Vector(0 * scale, -49 * scale));
        bStrut.push(new Vector(-28 * scale, -49 * scale));
        bStrut.push(new Vector(-28 * scale, -31.5 * scale));
        rBody.addShape(new Polygon(bStrut, offset));
        
        // Bottom Wing
        var bWing = new Array();
        bWing.push(new Vector(-70 * scale, -49 * scale));
        bWing.push(new Vector(28 * scale, -49 * scale));
        bWing.push(new Vector(28 * scale, -70 * scale));
        bWing.push(new Vector(-42 * scale, -70 * scale));
        rBody.addShape(new Polygon(bWing, offset));

        world.addBody(rBody);
        //setPlanetGravity();
        //calcRadius();
    }
}