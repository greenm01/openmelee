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
    
    // Broadphase (HGrid) parameters
    public var bucket : Int;
    public var level : Int;
    public var radius : Float;
    public var diameter : Float;
    public var size : Int;
    public var next : Body;

    public function new(position:Vec2, ang:Float) {
        setAngle(ang);
        var R = new Mat22(new Vec2(0,0), new Vec2(0,0));
        R.set(ang);
        xf = new XForm(position, R);
    }
    
    private inline function initHGrid() {
        // Initialize HGrid information
        size = HGrid.MIN_CELL_SIZE;
        diameter = 2.0 * radius;
        level = 0;
        while(size * HGrid.SPHERE_TO_CELL_RATIO < diameter) {
            size *= Std.int(HGrid.CELL_TO_CELL_RATIO);
            level++;
        }
    }
    
    public function addShape(shape:Shape) {
        // TODO: Calculate max radius from shapes;
        initHGrid();
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
        return m_xf.position;
    }
    
    private inline function setPos(p:Vec2) {
        m_xf.position = p;
        synchronizeTransform();
        return m_xf.position;
    }
    
    private inline function setAngle(a:Float) {
        m_angle = a;
        synchronizeTransform();
        return m_angle;
    }
    
    private inline function getAngle() {
        return m_angle;
    }
    
    /**
     * Update rotation and position of the body
     */
    public function synchronizeTransform()
    {
        m_xf.R.set(m_angle);
        m_xf.position = m_xf.position.sub(Vec2.mul22(m_xf.R, localCenter));
    }
    
    /// The body's origin transform
    private var m_xf : XForm;
    /// The body's angle in radians;
    private var m_angle : Float;

}
