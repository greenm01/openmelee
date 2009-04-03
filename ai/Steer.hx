/*
 * Copyright (c) 2009, Mason Green (zzzzrrr)
 * http://www.dsource.org/projects/openmelee
 * Based on OpenSteer, Copyright (c) 2002-2003, Sony Computer Entertainment America
 * Original author: Craig Reynolds
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
module openmelee.ai.steer;

import tango.io.Stdout : Stdout;
import tango.util.container.LinkedList : LinkedList;

import blaze.common.bzMath: bzDot, bzClamp, bzVec2;
import blaze.collision.shapes.bzShape : bzShape;
import tango.math.Math : sqrt;
import blaze.dynamics.bzBody: bzBody;

import openmelee.ships.ship : Ship, State;
import openmelee.ai.utilities;
import openmelee.ai.ai : Threat;

alias LinkedList!(Ship) ObjectList;

class Steer 
{

    ObjectList objectList;
    
    // Constructor: initializes state
    this (Ship ship, ObjectList objectList)
    {
        this.objectList = objectList;
        m_ship = ship;
        m_body = ship.rBody;
    }
    
	struct PathIntersection
    {
        bool intersect;
        float distance;
        bzVec2 surfacePoint;
        bzVec2 surfaceNormal;
        bzBody obstacle;
    }

    // reset state
    void reset () {
        // initial state of wander behavior
        m_wanderSide = 0;
        m_wanderUp = 0;
    }
    
    void update() {
        m_position = m_ship.state.position;
        m_velocity = m_ship.state.velocity;
        m_speed = m_ship.state.speed;
        m_maxForce = m_ship.state.maxForce;
        m_forward = m_ship.state.forward;
        m_radius = m_ship.state.radius;
    }

    // -------------------------------------------------- steering behaviors

    bzVec2 steerForWander (float dt) {
        // random walk m_wanderSide and m_wanderUp between -1 and +1
        float speed = 12 * dt; // maybe this (12) should be an argument?
        m_wanderSide = scalarRandomWalk (m_wanderSide, speed, -1, +1);
        m_wanderUp   = scalarRandomWalk (m_wanderUp,   speed, -1, +1);

        // return a pure lateral steering vector: (+/-Side) + (+/-Up)
        return (m_side * m_wanderSide) + (m_up * m_wanderUp);
    }

    // Seek behavior
    bzVec2 steerForSeek (bzVec2 target) {
        bzVec2 desiredVelocity = target - m_position;
        return desiredVelocity - m_velocity;
    }

    // Flee behavior
    bzVec2 steerForFlee (bzVec2 target) {
        bzVec2 desiredVelocity = m_position - target;
        return desiredVelocity - m_velocity;
    }

    /*
    // xxx proposed, experimental new seek/flee [cwr 9-16-02]
    bzVec2 xxxsteerForFlee (bzVec2 target) {
        bzVec2 offset = m_position - target;
        bzVec2 desiredVelocity = bzClamp(offset.truncateLength (maxSpeed ());
        return desiredVelocity - m_velocity;
    }

    bzVec2 xxxsteerForSeek (bzVec2 target) {
        //  bzVec2 offset = target - position;
        bzVec2 offset = target - m_position;
        bzVec2 desiredVelocity = offset.truncateLength (maxSpeed ()); //xxxnew
        return desiredVelocity - m_velocity;
    }
    */

	/*
    // ------------------------------------------------------------------------
    // Obstacle Avoidance behavior
    //
    // Returns a steering force to avoid a given obstacle.  The purely
    // lateral steering force will turn our vehicle towards a silhouette edge
    // of the obstacle.  Avoidance is required when (1) the obstacle
    // intersects the vehicle's current path, (2) it is in front of the
    // vehicle, and (3) is within minTimeToCollision seconds of travel at the
    // vehicle's current velocity.  Returns a zero vector value (bzVec2::zero)
    // when no avoidance is required.
    bzVec2 steerToAvoidObstacle (float minTimeToCollision, Obstacle obstacle) {

        bzVec2 avoidance = obstacle.steerToAvoid (this, minTimeToCollision);
        return avoidance;
    }
    */
    
    // Steer to avoid
    void collisionThreat(inout Threat threat, float maxLookAhead = 10.0f) {

        // 1. Find the target that’s closest to collision
        
        float radius = m_radius;
        float rad = 0.0f;
        float shortestTime = float.max;
    
        // Loop through each target
        foreach(obstacle; objectList) {

            bzBody target = obstacle.rBody;
            
            if(target is m_body) continue;
            
            // Calculate the time to collision
            bzVec2 relativePos = target.position - m_position;
            bzVec2 relativeVel = m_velocity - target.linearVelocity;
            float relativeSpeed = relativeVel.length;
            // Time to closest point of approach
            float timeToCPA = bzDot(relativePos, relativeVel) /
                                    (relativeSpeed * relativeSpeed);
                            
            // Threat is separating 
            if(timeToCPA < 0) {
                continue;
            } 
            
            float distance = relativePos.length;
            
            // Clamp look ahead time
            timeToCPA = bzClamp(timeToCPA, 0, maxLookAhead);
            
            // Calculate closest point of approach
            bzVec2 cpa = m_position + m_velocity * timeToCPA;
            bzVec2 eCpa = target.position + target.linearVelocity * timeToCPA;
            relativePos = (eCpa - cpa);
            float dCPA = relativePos.length;
                
            // No collision
            if (dCPA > radius + obstacle.state.radius) continue;

            // Check if it's the closest collision threat
            if (timeToCPA < shortestTime && dCPA < threat.minSeparation) {
                shortestTime = timeToCPA;
                threat.target = obstacle;
                threat.distance = distance;
                threat.relativePos = relativePos;
                threat.relativeVel = relativeVel;
                threat.minSeparation = dCPA;
                rad = obstacle.state.radius;
            }
        }
        
        // 2. Calculate the steering

        // If we have no target, then exit
        if(!threat.target) return;
        
        // If we’re going to hit exactly, or if we’re already
        // colliding, then do the steering based on current
        // position.
        //if(threat.minSeparation < m_radius || threat.distance < radius + rad) {
            //threat.steering =  m_position - threat.target.state.position;
        //} else {
            // Otherwise calculate the future relative position:
            threat.steering = threat.relativePos; 
        //}
    }

    /*
    // ------------------------------------------------------------------------
    // Unaligned collision avoidance behavior: avoid colliding with other
    // nearby vehicles moving in unconstrained directions.  Determine which
    // (if any) other other vehicle we would collide with first, then steers
    // to avoid the site of that potential collision.  Returns a steering
    // force vector, which is zero length if there is no impending collision.

    bzVec2 steerToAvoidNeighbors (float minTimeToCollision, AVGroup others) {

        // first priority is to prevent immediate interpenetration
        bzVec2 separation = steerToAvoidCloseNeighbors (0, others);
        if (separation != bzVec2::zero) return separation;

        // otherwise, go on to consider potential future collisions
        float steer = 0;
        Ship threat;

        // Time (in seconds) until the most immediate collision threat found
        // so far.  Initial value is a threshold: don't look more than this
        // many frames into the future.
        float minTime = minTimeToCollision;

        // xxx solely for annotation
        bzVec2 xxxThreatPositionAtNearestApproach;
        bzVec2 xxxOurPositionAtNearestApproach;

        // for each of the other vehicles, determine which (if any)
        // pose the most immediate threat of collision.
        for (AVIterator i = others.begin(); i != others.end(); i++)
        {
            Ship other = i;
            if (other !is this)
            {
                // avoid when future positions are this close (or less)
                float collisionDangerThreshold = radius * 2;

                // predicted time until nearest approach of "this" and "other"
                float time = predictNearestApproachTime (other);

                // If the time is in the future, sooner than any other
                // threatened collision...
                if ((time >= 0)  (time < minTime))
                {
                    // if the two will be close enough to collide,
                    // make a note of it
                    if (computeNearestApproachPositions (other, time)
                        < collisionDangerThreshold)
                    {
                        minTime = time;
                        threat = other;
                        xxxThreatPositionAtNearestApproach
                            = hisPositionAtNearestApproach;
                        xxxOurPositionAtNearestApproach
                            = ourPositionAtNearestApproach;
                    }
                }
            }
        }

        // if a potential collision was found, compute steering to avoid
        if (threat)
        {
            // parallel: +1, perpendicular: 0, anti-parallel: -1
            float parallelness = m_forward.dot(threat.forward);
            float angle = 0.707f;

            if (parallelness < -angle)
            {
                // anti-parallel "head on" paths:
                // steer away from future threat position
                bzVec2 offset = xxxThreatPositionAtNearestApproach - m_position;
                float sideDot = offset.dot(m_side());
                steer = (sideDot > 0) ? -1.0f : 1.0f;
            }
            else
            {
                if (parallelness > angle)
                {
                    // parallel paths: steer away from threat
                    bzVec2 offset = threat.position - m_position;
                    float sideDot = bzDot(offset, m_side);
                    steer = (sideDot > 0) ? -1.0f : 1.0f;
                }
                else
                {
                    // perpendicular paths: steer behind threat
                    // (only the slower of the two does this)
                    if (threat.speed() <= speed)
                    {
                        float sideDot = bzDot(m_side, threat.velocity);
                        steer = (sideDot > 0) ? -1.0f : 1.0f;
                    }
                }
            }
        }

        return m_side() * steer;
    }
	*/
	
    // Given two vehicles, based on their current positions and velocities,
    // determine the time until nearest approach
    float predictNearestApproachTime (State other) {

        // imagine we are at the origin with no velocity,
        // compute the relative velocity of the other vehicle
        bzVec2 myVelocity = m_velocity;
        bzVec2 otherVelocity = other.velocity;
        bzVec2 relVelocity = otherVelocity - myVelocity;
        float relSpeed = relVelocity.length;

        // for parallel paths, the vehicles will always be at the same distance,
        // so return 0 (aka "now") since "there is no time like the present"
        if (relSpeed == 0) return 0;

        // Now consider the path of the other vehicle in this relative
        // space, a line defined by the relative position and velocity.
        // The distance from the origin (our vehicle) to that line is
        // the nearest approach.

        // Take the unit tangent along the other vehicle's path
        bzVec2 relTangent = relVelocity / relSpeed;

        // find distance from its path to origin (compute offset from
        // other to us, find length of projection onto path)
        bzVec2 relPosition = m_position - other.position;
        float projection = bzDot(relTangent, relPosition);

        return projection / relSpeed;
    }

    // Given the time until nearest approach (predictNearestApproachTime)
    // determine position of each vehicle at that time, and the distance
    // between them
    float computeNearestApproachPositions (State other, float time) {

        bzVec2 myTravel =  m_forward *  m_speed * time;
        bzVec2 otherTravel = other.forward * other.speed * time;

        bzVec2 myFinal =  m_position + myTravel;
        bzVec2 otherFinal = other.position + otherTravel;

        return (myFinal - otherFinal).length;
    }

    bzVec2 targetEnemy (State quarry, float maxPredictionTime) {

        // offset from this to quarry, that distance, unit vector toward quarry
        bzVec2 offset = quarry.position - m_position;
        float distance = offset.length;
        bzVec2 unitOffset = offset / distance;

        // how parallel are the paths of "this" and the quarry
        // (1 means parallel, 0 is pependicular, -1 is anti-parallel)
        float parallelness = bzDot(m_forward , quarry.forward);

        // how "forward" is the direction to the quarry
        // (1 means dead ahead, 0 is directly to the side, -1 is straight back)
        float forwardness = bzDot(m_forward , unitOffset);

        float directTravelTime = distance / m_speed;
        int f = intervalComparison (forwardness,  -0.707f, 0.707f);
        int p = intervalComparison (parallelness, -0.707f, 0.707f);

        float timeFactor = 0; // to be filled in below

        // Break the pursuit into nine cases, the cross product of the
        // quarry being [ahead, aside, or behind] us and heading
        // [parallel, perpendicular, or anti-parallel] to us.
        switch (f)
        {
        case +1:
            switch (p)
            {
            case +1:          // ahead, parallel
                timeFactor = 4;
                break;
            case 0:           // ahead, perpendicular
                timeFactor = 1.8f;
                break;
            case -1:          // ahead, anti-parallel
                timeFactor = 0.85f;
                break;
            }
            break;
        case 0:
            switch (p)
            {
            case +1:          // aside, parallel
                timeFactor = 1;
                break;
            case 0:           // aside, perpendicular
                timeFactor = 0.8f;
                break;
            case -1:          // aside, anti-parallel
                timeFactor = 4;
                break;
            }
            break;
        case -1:
            switch (p)
            {
            case +1:          // behind, parallel
                timeFactor = 0.5f;
                break;
            case 0:           // behind, perpendicular
                timeFactor = 2;
                break;
            case -1:          // behind, anti-parallel
                timeFactor = 2;
                break;
            }
            break;
        }

        // estimated time until intercept of quarry
        float et = directTravelTime * timeFactor;

        // xxx experiment, if kept, this limit should be an argument
        float etl = (et > maxPredictionTime) ? maxPredictionTime : et;

        // estimated position of quarry at intercept
        bzVec2 target = quarry.predictFuturePosition(etl);
        return target; 
    }

    // ------------------------------------------------------------------------
    // evasion of another vehicle
    bzVec2 steerForEvasion (State menace,  float maxPredictionTime)  {

        // offset from this to menace, that distance, unit vector toward menace
        bzVec2 offset = menace.position - m_position;
        float distance = offset.length;

        float roughTime = distance / menace.speed;
        float predictionTime = ((roughTime > maxPredictionTime) ? maxPredictionTime : roughTime);
        bzVec2 target = menace.predictFuturePosition (predictionTime);

        return steerForFlee (target);
    }


    // ------------------------------------------------------------------------
    // tries to maintain a given speed, returns a maxForce-clipped steering
    // force along the forward/backward axis
    bzVec2 steerForTargetSpeed (float targetSpeed) {
        float mf = m_maxForce;
        float speedError = targetSpeed - m_speed;
        return m_forward * bzClamp(speedError, -mf, +mf);
    }


    // ----------------------------------------------------------- utilities
    bool isAhead (bzVec2 target) {return isAhead (target, 0.707f);};
    bool isAside (bzVec2 target) {return isAside (target, 0.707f);};
    bool isBehind (bzVec2 target) {return isBehind (target, -0.707f);};

    bool isAhead (bzVec2 target, float cosThreshold)
    {
        bzVec2 targetDirection = target - m_position;
        targetDirection.normalize();
        return bzDot(m_forward, targetDirection) > cosThreshold;
    }

    bool isAside (bzVec2 target, float cosThreshold)
    {
        bzVec2 targetDirection = target - m_position;
        targetDirection.normalize();
        float dp = bzDot(m_forward, targetDirection);
        return (dp < cosThreshold) && (dp > -cosThreshold);
    }

    bool isBehind (bzVec2 target, float cosThreshold)
    {
        bzVec2 targetDirection = target - m_position;
        targetDirection.normalize();
        return bzDot(m_forward, targetDirection) < cosThreshold;
    }
    
    private:
    
    Ship m_ship;
    
    bzVec2 m_position;
    bzVec2 m_velocity;
    bzVec2 m_up;
    bzVec2 m_side;
    bzVec2 m_forward;
    float m_radius;
    bzBody m_body;
	
	float m_speed = 0;
	float m_maxForce = 0;
    
    // Wander behavior
    float m_wanderSide;
    float m_wanderUp;
}
