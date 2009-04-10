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
package ai;

import phx.Vector;
import phx.Shape;
import phx.Body;

import ships.State;
import ships.Ship;

class Steer 
{

    var objectList:FastList<Ship>;
    
    // Constructor: initializes state
    public function new (ship:Ship, objectList:FastList<Ship>)
    {
        this.objectList = objectList;
        m_ship = ship;
        m_body = ship.rBody;
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

    function steerForWander (dt:Float) {
        // random walk m_wanderSide and m_wanderUp between -1 and +1
        var speed = 12 * dt; // maybe this (12) should be an argument?
        m_wanderSide = scalarRandomWalk (m_wanderSide, speed, -1, +1);
        m_wanderUp   = scalarRandomWalk (m_wanderUp,   speed, -1, +1);

        // return a pure lateral steering vector: (+/-Side) + (+/-Up)
        return (m_side * m_wanderSide) + (m_up * m_wanderUp);
    }

    // Seek behavior
    function steerForSeek (target:Vector) {
        var desiredVelocity = target - m_position;
        return desiredVelocity - m_velocity;
    }

    // Flee behavior
    public function steerForFlee (target:Vector) {
        bzVec2 desiredVelocity = m_position - target;
        return desiredVelocity - m_velocity;
    }
    
    // Steer to avoid
    void collisionThreat(threat:Treat, maxLookAhead:Float = 10.0) {

        // 1. Find the target that’s closest to collision
        
        var radius = m_radius;
        var rad = 0.0;
        var shortestTime = float.max;
    
        // Loop through each target
        for(obstacle in objectList) {

            var target = obstacle.rBody;
            
            if(target is m_body) continue;
            
            // Calculate the time to collision
            var relativePos = target.position - m_position;
            var relativeVel = m_velocity - target.linearVelocity;
            var relativeSpeed = relativeVel.length;
            // Time to closest point of approach
            var timeToCPA = bzDot(relativePos, relativeVel) /
                                    (relativeSpeed * relativeSpeed);
                            
            // Threat is separating 
            if(timeToCPA < 0) {
                continue;
            } 
            
            var distance = relativePos.length();
            
            // Clamp look ahead time
            timeToCPA = Vector.clamp(timeToCPA, 0, maxLookAhead);
            
            // Calculate closest point of approach
            var cpa = m_position + m_velocity * timeToCPA;
            var eCpa = target.position + target.linearVelocity * timeToCPA;
            relativePos = (eCpa - cpa);
            var dCPA = relativePos.length();
                
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
	
    // Given two vehicles, based on their current positions and velocities,
    // determine the time until nearest approach
    function predictNearestApproachTime (other:State) {

        // imagine we are at the origin with no velocity,
        // compute the relative velocity of the other vehicle
        var myVelocity = m_velocity;
        var otherVelocity = other.velocity;
        var relVelocity = otherVelocity - myVelocity;
        var relSpeed = relVelocity.length;

        // for parallel paths, the vehicles will always be at the same distance,
        // so return 0 (aka "now") since "there is no time like the present"
        if (relSpeed == 0) return 0;

        // Now consider the path of the other vehicle in this relative
        // space, a line defined by the relative position and velocity.
        // The distance from the origin (our vehicle) to that line is
        // the nearest approach.

        // Take the unit tangent along the other vehicle's path
        var relTangent = relVelocity / relSpeed;

        // find distance from its path to origin (compute offset from
        // other to us, find length of projection onto path)
        var relPosition = m_position - other.position;
        var projection = bzDot(relTangent, relPosition);

        return projection / relSpeed;
    }

    // Given the time until nearest approach (predictNearestApproachTime)
    // determine position of each vehicle at that time, and the distance
    // between them
    function computeNearestApproachPositions (other:State, time:Float) {

        bzVec2 myTravel =  m_forward *  m_speed * time;
        bzVec2 otherTravel = other.forward * other.speed * time;

        bzVec2 myFinal =  m_position + myTravel;
        bzVec2 otherFinal = other.position + otherTravel;

        return (myFinal - otherFinal).length;
    }

    public function targetEnemy (quarry:State, maxPredictionTime:Float) {

        // offset from this to quarry, that distance, unit vector toward quarry
        var offset = quarry.position - m_position;
        var distance = offset.length;
        var unitOffset = offset / distance;

        // how parallel are the paths of "this" and the quarry
        // (1 means parallel, 0 is pependicular, -1 is anti-parallel)
        var parallelness = bzDot(m_forward , quarry.forward);

        // how "forward" is the direction to the quarry
        // (1 means dead ahead, 0 is directly to the side, -1 is straight back)
        var forwardness = bzDot(m_forward , unitOffset);

        var directTravelTime = distance / m_speed;
        var f = intervalComparison (forwardness,  -0.707f, 0.707f);
        var p = intervalComparison (parallelness, -0.707f, 0.707f);

        var timeFactor = 0; // to be filled in below

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
        var et = directTravelTime * timeFactor;

        // xxx experiment, if kept, this limit should be an argument
        var etl = (et > maxPredictionTime) ? maxPredictionTime : et;

        // estimated position of quarry at intercept
        var target = quarry.predictFuturePosition(etl);
        return target; 
    }

    // ------------------------------------------------------------------------
    // evasion of another vehicle
    public function steerForEvasion (menace:State,  maxPredictionTime:Float)  {

        // offset from this to menace, that distance, unit vector toward menace
        var offset = menace.position - m_position;
        var distance = offset.length;

        var roughTime = distance / menace.speed;
        var predictionTime = ((roughTime > maxPredictionTime) ? maxPredictionTime : roughTime);
        var target = menace.predictFuturePosition (predictionTime);

        return steerForFlee (target);
    }


    // ------------------------------------------------------------------------
    // tries to maintain a given speed, returns a maxForce-clipped steering
    // force along the forward/backward axis
    public function steerForTargetSpeed (targetSpeed:Float) {
        var mf = m_maxForce;
        var speedError = targetSpeed - m_speed;
        return m_forward * Vector.clamp(speedError, -mf, +mf);
    }


    // ----------------------------------------------------------- utilities
    function isAhead (target:Vector) {return isAhead2 (target, 0.707);};
    function isAside (target:Vector) {return isAside2 (target, 0.707);};
    function isBehind (target:Vector) {return isBehind2 (target, -0.707);};

    function isAhead2 (target:Vector, cosThreshold:Float)
    {
        var targetDirection = target - m_position;
        targetDirection.normalize();
        return bzDot(m_forward, targetDirection) > cosThreshold;
    }

    function isAside2 (target:Vector, cosThreshold:Float)
    {
        var targetDirection = target - m_position;
        targetDirection.normalize();
        var dp = bzDot(m_forward, targetDirection);
        return (dp < cosThreshold) && (dp > -cosThreshold);
    }

    function isBehind2 (target:Vector, cosThreshold:Float)
    {
        var targetDirection = target - m_position;
        targetDirection.normalize();
        return m_forward.dot(targetDirection) < cosThreshold;
    }

    m_ship : Ship;
    
    m_position : Vector;
    m_velocity: Vector;
    m_up : Vector;
    m_side : Vector;
    m_forward : Vector;
    m_radius : Float;
    m_body : Body;
	
	m_speed : Float;
	m_maxForce : Float;
    
    // Wander behavior
    m_wanderSide : Float;
    m_wanderUp : Float;
}
