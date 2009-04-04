package haxmel.physics

import haxmel.utils.XForm;
umport haxmel.utils.Util;

class Body
{

    /// Center of mass in local coordinates
    public var localCenter : Vec2;
    public var angle(getAngle, setAngle) : Float;
    public var position(getPos, setPos) : Vec2;
    
    public function new(position:Vec2, angle:Float) {
        this.angle = angle;
        var R = new Mat22(new Vector(0,0), new Vector(0,0);
        R.set(angle);
        xf = new XForm(position, R);
    }
    
    /**
     * Gets a local vector given a world vector.
     * Params: worldVector a vector in world coordinates.
     * Returns: the corresponding local vector.
     */
    public inline function localVector(worldVector:Vec2){
        return mul22(xf.R, worldVector);
    }
    
    private inline function getPos() {
        return m_xf.position;
    }
    
    private inline function setPos(p:Vec2) {
        m_xf.position = p;
        synchronizeTransform();
    }
    
    private function setAngle(a:Float)
    {
        m_angle = a;
        synchronizeTransform();
    }
    
    private inline function getAngle() {
        return m_angle;
    }
    
    /**
     * Update rotation and position of the body
     */
    public inline function synchronizeTransform()
    {
        m_xf.R.set(m_angle);
        m_xf.position = m_xf.position.sub(mulXF(m_xf.R, localCenter));
    }
    
    /// The body's origin transform
    private var m_xf : XForm;
    /// The body's angle in radians;
    private var m_angle : Float;

}
