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
package physics;

import haxe.FastList;

import utils.XForm;
import utils.Vec2;
import utils.Mat22;

class Body
{

    /// Center of mass in local coordinates
    public var localCenter : Vec2;
    public var xf : XForm;
    public var angle(getAngle, setAngle) : Float;
    public var pos(getPos, setPos) : Vec2;
    public var linVel : Vec2;
    public var angVel : Float;
    public var force : Vec2;
    public var torque : Float;
    
    public var linearDamping : Float;
    public var angularDamping : Float;
    
    // Mass properties
    var mass : Float;
    public var invMass : Float;
    var I : Float;
    public var invI : Float;
    
    public var shapeList : FastList<Shape>;
    
    // Broadphase (HGrid) parameters
    public var bucket : Int;
    public var level : Int;
    public var radius : Float;
    public var diameter : Float;
    public var size : Int;
    public var next : Body;

    public function new(position:Vec2, angle:Float) {
        m_angle = angle;
        var R = Mat22.init();
        R.set(angle);
        xf = new XForm(position, R);
        shapeList = new FastList();
        
        linearDamping = 0.0;
        angularDamping = 0.0;
        angVel = 0.0;
        torque = 0.0;
        radius = 0.0;
        
        force = Vec2.init();
        linVel = Vec2.init();
        localCenter = Vec2.init();
    }
    
    public function addShape(s:Shape) {
        
        shapeList.add(s);
		s.body = this;
        
        // Update body's radius
        var sRad = s.offset.length() + s.radius;
        if(radius < sRad) {
            radius = sRad;
        }
        
        // Initialize HGrid information
        size = HGrid.MIN_CELL_SIZE;
        diameter = 2.0 * radius;
        level = 0;
        while(size * HGrid.SPHERE_TO_CELL_RATIO < diameter) {
            size *= Std.int(HGrid.CELL_TO_CELL_RATIO);
            level++;
        }

    }
    
    /**
     * Compute the mass properties from the attached shapes. You typically call
     * this after adding all the shapes. If you add or remove shapes later, you
     * may want to call this again. Note that this changes the center of mass
     * position.
     */
    public function setMassFromShapes() {
        // Compute mass data from shapes. Each shape has its own density.
        mass = 0.0;
        invMass = 0.0;
        I = 0.0;
        invI = 0.0;

        var center = new Vec2(0.0, 0.0);
        for (s in shapeList) {
            s.computeMass();
            mass += s.massData.mass;
            center.addAsn(s.massData.center.mul(s.massData.mass));
            I += s.massData.I;
        }

        // Compute center of mass, and shift the origin to the COM.
        if (mass > 0.0) {
            invMass = 1.0 / mass;
            center.mulAsn(invMass);
        }

        if (I > 0.0) {
            // Center the inertia about the center of mass.
            I -= mass * center.dot(center);
            if(I < 0.0) throw "mass error";
            invI = 1.0 / I;
        } else {
            I = 0.0;
            invI = 0.0;
        }
        // Update center of mass.
        localCenter = center;
    }
    
    /**
     * Gets a local vector given a world vector.
     * Params: worldVector a vector in world coordinates.
     * Returns: the corresponding local vector.
     */
    public inline function localVector(worldVector:Vec2){
        return Vec2.mul22(xf.R, worldVector);
    }
    
    private inline function getPos() {
        return xf.position;
    }
    
    private inline function setPos(p:Vec2) {
        xf.position = p;
        return xf.position;
    }
    
    private inline function setAngle(a:Float) {
        m_angle = a;
        return m_angle;
    }
    
    private inline function getAngle() {
        return m_angle;
    }
    
    /**
     * Update body's rotation
     */
    public inline function synchronizeTransform() {
        xf.R.set(m_angle);
    }
    
    /**
     * Update world vertices
     */
    public inline function synchronizeShapes() {
        for(s in shapeList) {
            s.synchronize();
        }
    }
    
    /// The body's angle in radians;
    private var m_angle : Float;

}
