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
