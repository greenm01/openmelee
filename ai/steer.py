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
class Steer(object):

    actors : Sprite
    
    # Constructor: initializes state
    def __init__ (self, ship, actors):
        self.actors = actors
        self.ship = ship
        self.body = ship.body
        self.threat = Threat()

    # -------------------------------------------------- steering behaviors
    
    def steerForWander(dt):
        # random walk m_wanderSide and m_wanderUp between -1 and +1
        # maybe (12) should be an argument?
        speed = 12 * dt 
        m_wanderSide = Util.scalarRandomWalk (m_wanderSide, speed, -1, 1)
        m_wanderUp   = Util.scalarRandomWalk (m_wanderUp,   speed, -1, 1)

        # return a pure lateral steering vector: (+/-Side) + (+/-Up)
        return m_side * m_wanderSide + m_up * m_wanderUp
    

    # Seek behavior
    def steer_for_seek(target):
        desired_velocity = target - self.body.position
        return desired_velocity - self.body.linear_velocity
    

    # Flee behavior
    def steer_for_free(target):
        desired_velocity = target - self.body.position
        return desired_velocity - self.body.linear_velocity
    
    
    # Steer to avoid
    def collisionThreat(threat, max_look_ahead = 0.15):

        # 1. Find the target closest to collision
        
        radius = self.ship.radius
        shortest_time = 1e99
    
        # Loop through each target
        for target in actors:
            
            if target.body is self.body or target.body is None or
               self.group is target.group:
                continue
            
            # Calculate the time to collision
            relative_position = target.body.position - self.body.position
            relative_velocity = self.body.linear_velocity - target.body.linear_velocity
            relative_speed = relative_vel.length()
            
            # Time to closest point of approach
            time_cpa = relative_pos.dot(relative_velocity) /
                        (relative_speed * relative_speed)
                                    
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

        # If we’re going to hit exactly, or if we’re already
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
    

    def target(quarry:State, maxPredictionTime:Float):

        # offset from self to quarry, that distance, unit vector toward quarry
        offset = quarry.pos.minus(self.position)
        distance = offset.length()
        unitOffset = offset.div(distance)

        # how parallel are the paths of "self" and the quarry
        # (1 means parallel, 0 is pependicular, -1 is anti-parallel)
        parallelness = self.forward.dot(quarry.forward)

        # how "forward" is the direction to the quarry
        # (1 means dead ahead, 0 is directly to the side, -1 is straight back)
        forwardness = self.forward.dot(unitOffset)

        directTravelTime = distance / self.speed
        f = Util.intervalComparison (forwardness,  -0.707, 0.707)
        p = Util.intervalComparison (parallelness, -0.707, 0.707)

        timeFactor = 0.0 # to be filled in below

        # Break the pursuit into nine cases, the cross product of the
        # quarry being [ahead, aside, or behind] us and heading
        # [parallel, perpendicular, or anti-parallel] to us.
        switch (f)
        {
        case 1:
            switch (p)
            {
            case 1:          # ahead, parallel
                timeFactor = 4.0
            case 0:           # ahead, perpendicular
                timeFactor = 1.8
            case -1:          # ahead, anti-parallel
                timeFactor = 0.85
            }
        case 0:
            switch (p)
            {
            case 1:          # aside, parallel
                timeFactor = 1.0
            case 0:           # aside, perpendicular
                timeFactor = 0.8
            case -1:          # aside, anti-parallel
                timeFactor = 4.0
            }
        case -1:
            switch (p)
            {
            case 1:          # behind, parallel
                timeFactor = 0.5
            case 0:           # behind, perpendicular
                timeFactor = 2.0
            case -1:          # behind, anti-parallel
                timeFactor = 2.0
            }
        }

        # estimated time until intercept of quarry
        et = directTravelTime * timeFactor

        # xxx experiment, if kept, self limit should be an argument
        etl = if (et > maxPredictionTime) maxPredictionTime else et

        # estimated position of quarry at intercept
        target = quarry.predictFuturePosition(etl)
        return target 
    

    # ------------------------------------------------------------------------
    # evasion of another vehicle
    def steerForEvasion (menace:State,  maxPredictionTime:Float):

        # offset from self to menace, that distance, unit vector toward menace
        offset = menace.pos.minus(self.position)
        distance = offset.length()

        roughTime = distance / menace.speed
        predictionTime = if (roughTime > maxPredictionTime) maxPredictionTime else roughTime
        target = menace.predictFuturePosition (predictionTime)

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