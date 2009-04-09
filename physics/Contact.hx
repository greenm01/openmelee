/*
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
 package physics;

import utils.Vec2;

 class Contact
 {

    public var shape1 : Shape;
    public var shape2 : Shape;
    public var normal : Vec2;
    public var cp1 : Vec2;
    public var cp2 : Vec2;
    public var r1 : Vec2;
    public var r2 : Vec2;
    
    public var massNormal : Float;
    public var massTangent : Float;
    public var bias : Float;
    public var separation : Float;
    
    public function new(shape1:Shape, shape2:Shape){
	this.shape1 = shape1;
	this.shape2 = shape2;
	normal = Vec2.init();
	cp1 = Vec2.init();
	cp2 = Vec2.init();
    r1 = Vec2.init();
    r2 = Vec2.init();
    separation = shape2.worldCenter.sub(shape1.worldCenter).length();
    }
 }
