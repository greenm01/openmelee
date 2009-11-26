#
# Copyright (c) 2009 Mason Green & Tom Novelli
#
# This file is part of OpenMelee.
#
# OpenMelee is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMelee is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>.
#
from physics import Vec2
    
class Threat(object):

    target = None
    steering  = None
    distance = 0.0
    collision_time = 1e308
    min_separation = 1e308
    relative_position = None
    relative_velocity = None
    
class Steer(object):

    # Constructor: initializes state
    def __init__ (self, ship, actors):
        self.actors = actors
        self.ship = ship
        self.body = ship.body
        self.threat = Threat()

    # -------------------------------------------------- steering behaviors
    '''
    def steerForWander(dt):
        # random walk m_wanderSide and m_wanderUp between -1 and +1
        # maybe (12) should be an argument?
        speed = 12 * dt 
        m_wanderSide = Util.scalarRandomWalk (m_wanderSide, speed, -1, 1)
        m_wanderUp   = Util.scalarRandomWalk (m_wanderUp,   speed, -1, 1)

        # return a pure lateral steering vector: (+/-Side) + (+/-Up)
        return m_side * m_wanderSide + m_up * m_wanderUp
    '''

    # Seek behavior
    def steer_for_seek(self, target):
        desired_velocity = target - self.body.position
        return desired_velocity - self.body.linear_velocity
    

    # Flee behavior
    def steer_for_free(self, target):
        desired_velocity = target - self.body.position
        return desired_velocity - self.body.linear_velocity
    
    
    # Steer to avoid
    def collision_threat(self, max_look_ahead = 0.15):

        # 1. Find the target closest to collision
        
        radius = self.ship.radius
        shortest_time = 1e99
    
        # Loop through each target
        for target in actors:
            
            if target.body is self.body or target.body is None or self.group is target.group:
                continue
            
            # Calculate the time to collision
            relative_position = target.body.position - self.body.position
            relative_velocity = self.body.linear_velocity - target.body.linear_velocity
            relative_speed = relative_vel.length()
            
            # Time to closest point of approach
            time_cpa = relative_pos.dot(relative_velocity) / (relative_speed * relative_speed)
                                    
            # Threat is separating 
            if (time_cpa < 0):
                continue
            
            distance = relative_position.length()
            # Clamp look ahead time
            time_cpa = clamp(time_cpa, 0, max_look_ahead)
            
            # Calculate closest point of approach
            cpa = self.body.position + self.body.linear_velocity * time_cpa
            ecpa = position + target.body.linear_velocity * time_cpa
            relative_pos = ecpa - cpa
            dcpa = relative_position.length()
            
            # No collision
            if (dcpa > radius + obstacle.radius):
                continue
            
            # Check if it's the closest collision threat
            if time_cpa < shortest_time and dcpa < self.threat.min_separation:
                shortest_time = time_cpa
                self.threat.target = obstacle
                self.threat.distance = distance
                self.threat.relative_position = relative_position
                self.threat.relative_velocity = relative_velocity
                self.threat.min_separation = dcpa
           

        # 2. Calculate the steering

        # If we have no target, then exit
        if threat.target is None:
            return None

        # If we arere going to hit exactly, or if we are already
        # colliding, then do the steering based on current
        # position.
        #if(threat.min_separation < self.radius || threat.distance < radius + rad) {
            #threat.steering =  self.position - threat.target.state.pos
        #} else {
            # Otherwise calculate the future relative position:
        threat.steering = threat.relative_position
        return threat.relative_position
            #trace(threat.steering.x + "," + threat.steering.y)
        #}
 
    '''
    # Given two vehicles, based on their current positions and velocities,
    # determine the time until nearest approach
    def predictNearestApproachTime (other:State):

        # imagine we are at the origin with no velocity,
        # compute the relative velocity of the other vehicle
        myVelocity = self.velocity
        otherVelocity = other.linVel
        relVelocity = otherVelocity.minus(myVelocity)
        relSpeed = relVelocity.length()

        # for parallel paths, the vehicles will always be at the same distance,
        # so return 0 (aka "now") since "there is no time like the present"
        if (relSpeed == 0.0) return 0.0

        # Now consider the path of the other vehicle in self relative
        # space, a line defined by the relative position and velocity.
        # The distance from the origin (our vehicle) to that line is
        # the nearest approach.

        # Take the unit tangent along the other vehicle's path
        relTangent = relVelocity.div(relSpeed)

        # find distance from its path to origin (compute offset from
        # other to us, find length of projection onto path)
        relPosition = self.position.minus(other.pos)
        projection : Float = relTangent.dot(relPosition)

        return projection / relSpeed
    }

    # Given the time until nearest approach (predictNearestApproachTime)
    # determine position of each vehicle at that time, and the distance
    # between them
    def computeNearestApproachPositions (other:State, time:Float):

        myTravel =  self.forward.mult(self.speed * time)
        otherTravel = other.forward.mult(other.speed * time)

        myFinal =  self.position.plus(myTravel)
        otherFinal = other.pos.plus(otherTravel)

        return myFinal.minus(otherFinal).length()
    '''

    def target(self, quarry, max_preditcion_time):
        
        # offset from self to quarry, that distance, unit vector toward quarry
        offset = quarry.body.position - self.body.position
        distance = offset.length
        unit_offset = offset / distance

        # how parallel are the paths of "self" and the quarry
        # (1 means parallel, 0 is pependicular, -1 is anti-parallel)
        fwd = self.ship.forward()
        forward = Vec2(fwd[0], fwd[1])
        fwd = quarry.forward()
        qforward = Vec2(fwd[0], fwd[1])
        parallelness = forward.dot(qforward)

        # how "forward" is the direction to the quarry
        # (1 means dead ahead, 0 is directly to the side, -1 is straight back)
        forwardness = forward.dot(unit_offset)
    
        vel = self.ship.body.linear_velocity.length
        direct_travel_time = 0.0 if vel == 0.0 else distance / vel
        f = interval_comparison (forwardness,  -0.707, 0.707)
        p = interval_comparison (parallelness, -0.707, 0.707)

        time_factor = 0.0 # to be filled in below

        # Break the pursuit into nine cases, the cross product of the
        # quarry being [ahead, aside, or behind] us and heading
        # [parallel, perpendicular, or anti-parallel] to us.
        if f == 1:
            if p == 1:              # ahead, parallel
                time_factor = 4.0
            elif p == 0:            # ahead, perpendicular
                time_factor = 1.8
            elif p == -1:           # ahead, anti-parallel
                time_factor = 0.85
        elif f == 0:
            if p == 1:              # aside, parallel
                time_factor = 1.0
            elif p == 0:            # aside, perpendicular
                time_factor = 0.8
            elif p == -1:           # aside, anti-parallel
                time_factor = 4.0
        elif f == -1:
            if p == 1:              # behind, parallel
                time_factor = 0.5
            elif p == 0:            # behind, perpendicular
                time_factor = 2.0
            elif p == -1:           # behind, anti-parallel
                time_factor = 2.0

        # estimated time until intercept of quarry
        et = direct_travel_time * time_factor

        # xxx experiment, if kept, self limit should be an argument
        etl = max_preditcion_time if et > max_preditcion_time else et

        # estimated position of quarry at intercept
        return quarry.body.position + quarry.body.linear_velocity * et  

    '''

    # ------------------------------------------------------------------------
    # evasion of another vehicle
    def steerForEvasion (menace:State,  max_preditcion_time:Float):

        # offset from self to menace, that distance, unit vector toward menace
        offset = menace.pos.minus(self.position)
        distance = offset.length()

        roughTime = distance / menace.speed
        predictionTime = if (roughTime > max_preditcion_time) max_preditcion_time else roughTime
        target = menace.predict_future_position (predictionTime)

        return steerForFlee (target)
    


    # ------------------------------------------------------------------------
    # tries to maintain a given speed, returns a maxForce-clipped steering
    # force along the forward/backward axis
    def steerForTargetSpeed (targetSpeed:Float):
        mf = self.maxForce
        speedError = targetSpeed - self.speed
        return self.forward.mult(Util.clamp(speedError, -mf, mf))


    # ----------------------------------------------------------- utilities
    def isAhead (target:Vector):
        return isAhead2 (target, 0.707)
        
    def isAside (target:Vector):
        return isAside2 (target, 0.707)
        
    def isBehind (target:Vector):
        return isBehind2 (target, -0.707)

    def isAhead2 (target:Vector, cosThreshold:Float):
        targetDirection = target.minus(self.position)
        targetDirection.normalize()
        return self.forward.dot(targetDirection) > cosThreshold

    def isAside2 (target:Vector, cosThreshold:Float):
        targetDirection = target.minus(self.position)
        targetDirection.normalize()
        dp = self.forward.dot(targetDirection)
        return (dp < cosThreshold) && (dp > -cosThreshold)

    def isBehind2 (target:Vector, cosThreshold:Float):
        targetDirection = target.minus(self.position)
        targetDirection.normalize()
        return self.forward.dot(targetDirection) < cosThreshold

    self.ship : GameObject
    
    self.position : Vector
    self.velocity: Vector
    m_up : Vector
    m_side : Vector
    self.forward : Vector
    self.radius : Float
    self.body : Body
    self.group : Int
    self.speed : Float
    self.maxForce : Float

    # Wander behavior
    m_wanderSide : Float
    m_wanderUp : Float
    '''
    
## classify a value relative to the interval between two bounds:
##     returns -1 when below the lower bound
##     returns  0 when between the bounds (inside the interval)
##     returns +1 when above the upper bound
def interval_comparison(x, lower_bound, upper_bound):
    if x < lower_bound: return -1
    if x > upper_bound: return 1
    return 0