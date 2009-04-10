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

import haxe.FastList;

import phx.Vector;
import phx.Shape;
import phx.Body;

import ships.Ship;
import ships.GameObject;
import ai.AI;
import utils.Util;

class Steer 
{

    var objectList:FastList<GameObject>;
    
    // Constructor: initializes state
    public function new (ship:Ship, objectList:FastList<GameObject>)
    {
        this.objectList = objectList;
        m_ship = ship;
        m_body = ship.rBody;
    }
    
    public function update() {
        m_position = m_ship.state.pos;
        m_velocity = m_ship.state.linVel;
        m_speed = m_ship.state.speed;
        m_maxForce = m_ship.state.maxForce;
        m_forward = m_ship.state.forward;
        m_radius = m_ship.state.radius;
    }

    // -------------------------------------------------- steering behaviors

    function steerForWander (dt:Float) {
        // random walk m_wanderSide and m_wanderUp between -1 and +1
        var speed = 12 * dt; // maybe this (12) should be an argument?
        m_wanderSide = Util.scalarRandomWalk (m_wanderSide, speed, -1, 1);
        m_wanderUp   = Util.scalarRandomWalk (m_wanderUp,   speed, -1, 1);

        // return a pure lateral steering vector: (+/-Side) + (+/-Up)
        return m_side.mult(m_wanderSide).plus(m_up.mult(m_wanderUp));
    }

    // Seek behavior
    function steerForSeek (target:Vector) {
        var desiredVelocity = target.minus(m_position);
        return desiredVelocity.minus(m_velocity);
    }

    // Flee behavior
    public function steerForFlee (target:Vector) {
        var desiredVelocity = m_position.minus(target);
        return desiredVelocity.minus(m_velocity);
    }
    
    // Steer to avoid
    public function collisionThreat(threat:Threat, maxLookAhead:Float = 10.0) {

        // 1. Find the target that’s closest to collision
        
        var radius = m_radius;
        var rad = 0.0;
        var shortestTime = 1e99;
    
        // Loop through each target
        for(obstacle in objectList) {

            var target = obstacle.rBody;
            
            if(target == m_body || target == null) continue;
            
            // Calculate the time to collision
            var pos = new Vector(target.x, target.y);
            var relativePos = pos.minus(m_position);
            var relativeVel = m_velocity.minus(target.v);
            var relativeSpeed = relativeVel.length();
            // Time to closest point of approach
            var timeToCPA = relativePos.dot(relativeVel) /
                                    (relativeSpeed * relativeSpeed);
                            
            // Threat is separating 
            if(timeToCPA < 0) {
                continue;
            } 
            
            var distance = relativePos.length();
            
            // Clamp look ahead time
            timeToCPA = Util.clamp(timeToCPA, 0, maxLookAhead);
            
            // Calculate closest point of approach
            var cpa = m_position.plus(m_velocity.mult(timeToCPA));
            var eCpa = pos.plus(target.v.mult(timeToCPA));
            relativePos = (eCpa.minus(cpa));
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
        if(threat.target == null) return;
        
        // If we’re going to hit exactly, or if we’re already
        // colliding, then do the steering based on current
        // position.
        //if(threat.minSeparation < m_radius || threat.distance < radius + rad) {
            //threat.steering =  m_position - threat.target.state.pos;
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
        var otherVelocity = other.linVel;
        var relVelocity = otherVelocity.minus(myVelocity);
        var relSpeed = relVelocity.length();

        // for parallel paths, the vehicles will always be at the same distance,
        // so return 0 (aka "now") since "there is no time like the present"
        if (relSpeed == 0.0) return 0.0;

        // Now consider the path of the other vehicle in this relative
        // space, a line defined by the relative position and velocity.
        // The distance from the origin (our vehicle) to that line is
        // the nearest approach.

        // Take the unit tangent along the other vehicle's path
        var relTangent = relVelocity.div(relSpeed);

        // find distance from its path to origin (compute offset from
        // other to us, find length of projection onto path)
        var relPosition = m_position.minus(other.pos);
        var projection : Float = relTangent.dot(relPosition);

        return projection / relSpeed;
    }

    // Given the time until nearest approach (predictNearestApproachTime)
    // determine position of each vehicle at that time, and the distance
    // between them
    function computeNearestApproachPositions (other:State, time:Float) {

        var myTravel =  m_forward.mult(m_speed * time);
        var otherTravel = other.forward.mult(other.speed * time);

        var myFinal =  m_position.plus(myTravel);
        var otherFinal = other.pos.plus(otherTravel);

        return myFinal.minus(otherFinal).length();
    }

    public function targetEnemy (quarry:State, maxPredictionTime:Float) {

        // offset from this to quarry, that distance, unit vector toward quarry
        var offset = quarry.pos.minus(m_position);
        var distance = offset.length();
        var unitOffset = offset.div(distance);

        // how parallel are the paths of "this" and the quarry
        // (1 means parallel, 0 is pependicular, -1 is anti-parallel)
        var parallelness = m_forward.dot(quarry.forward);

        // how "forward" is the direction to the quarry
        // (1 means dead ahead, 0 is directly to the side, -1 is straight back)
        var forwardness = m_forward.dot(unitOffset);

        var directTravelTime = distance / m_speed;
        var f = Util.intervalComparison (forwardness,  -0.707, 0.707);
        var p = Util.intervalComparison (parallelness, -0.707, 0.707);

        var timeFactor = 0.0; // to be filled in below

        // Break the pursuit into nine cases, the cross product of the
        // quarry being [ahead, aside, or behind] us and heading
        // [parallel, perpendicular, or anti-parallel] to us.
        switch (f)
        {
        case 1:
            switch (p)
            {
            case 1:          // ahead, parallel
                timeFactor = 4.0;
            case 0:           // ahead, perpendicular
                timeFactor = 1.8;
            case -1:          // ahead, anti-parallel
                timeFactor = 0.85;
            }
        case 0:
            switch (p)
            {
            case 1:          // aside, parallel
                timeFactor = 1.0;
            case 0:           // aside, perpendicular
                timeFactor = 0.8;
            case -1:          // aside, anti-parallel
                timeFactor = 4.0;
            }
        case -1:
            switch (p)
            {
            case 1:          // behind, parallel
                timeFactor = 0.5;
            case 0:           // behind, perpendicular
                timeFactor = 2.0;
            case -1:          // behind, anti-parallel
                timeFactor = 2.0;
            }
        }

        // estimated time until intercept of quarry
        var et = directTravelTime * timeFactor;

        // xxx experiment, if kept, this limit should be an argument
        var etl = if (et > maxPredictionTime) maxPredictionTime else et;

        // estimated position of quarry at intercept
        var target = quarry.predictFuturePosition(etl);
        return target; 
    }

    // ------------------------------------------------------------------------
    // evasion of another vehicle
    public function steerForEvasion (menace:State,  maxPredictionTime:Float)  {

        // offset from this to menace, that distance, unit vector toward menace
        var offset = menace.pos.minus(m_position);
        var distance = offset.length();

        var roughTime = distance / menace.speed;
        var predictionTime = if (roughTime > maxPredictionTime) maxPredictionTime else roughTime;
        var target = menace.predictFuturePosition (predictionTime);

        return steerForFlee (target);
    }


    // ------------------------------------------------------------------------
    // tries to maintain a given speed, returns a maxForce-clipped steering
    // force along the forward/backward axis
    public function steerForTargetSpeed (targetSpeed:Float) {
        var mf = m_maxForce;
        var speedError = targetSpeed - m_speed;
        return m_forward.mult(Util.clamp(speedError, -mf, mf));
    }


    // ----------------------------------------------------------- utilities
    function isAhead (target:Vector) {return isAhead2 (target, 0.707);}
    function isAside (target:Vector) {return isAside2 (target, 0.707);}
    function isBehind (target:Vector) {return isBehind2 (target, -0.707);}

    function isAhead2 (target:Vector, cosThreshold:Float)
    {
        var targetDirection = target.minus(m_position);
        targetDirection.normalize();
        return m_forward.dot(targetDirection) > cosThreshold;
    }

    function isAside2 (target:Vector, cosThreshold:Float)
    {
        var targetDirection = target.minus(m_position);
        targetDirection.normalize();
        var dp = m_forward.dot(targetDirection);
        return (dp < cosThreshold) && (dp > -cosThreshold);
    }

    function isBehind2 (target:Vector, cosThreshold:Float)
    {
        var targetDirection = target.minus(m_position);
        targetDirection.normalize();
        return m_forward.dot(targetDirection) < cosThreshold;
    }

    var m_ship : Ship;
    
    var m_position : Vector;
    var m_velocity: Vector;
    var m_up : Vector;
    var m_side : Vector;
    var m_forward : Vector;
    var m_radius : Float;
    var m_body : Body;
	
	var m_speed : Float;
	var m_maxForce : Float;
    
    // Wander behavior
    var m_wanderSide : Float;
    var m_wanderUp : Float;
}
