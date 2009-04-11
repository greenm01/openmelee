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
module openmelee.melee.contactListener;

import blaze.collision.bzCollision : bzContactID;
import blaze.dynamics.contact.bzContact : bzContactPoint, bzContactResult;
import blaze.dynamics.bzWorldCallbacks : bzContactListener;
import blaze.collision.shapes.bzShape : bzShape;
import blaze.common.bzMath : bzVec2;

import openmelee.melee.melee;

/*
enum ContactState {
    e_contactAdded,
    e_contactPersisted,
    e_contactRemoved
}
*/

// bzWorld contact callback
class ContactListener : bzContactListener
{

	Melee melee;

	this(Melee melee) {
		this.melee = melee;
	}

	void add(bzContactPoint point)
	{
		if (melee.pointCount == k_maxContactPoints) {
			return;
		}

		ContactPoint *cp = &melee.points[melee.pointCount];
		cp.shape1 = point.shape1;
		cp.shape2 = point.shape2;
		cp.position = point.position;
		cp.normal = point.normal;
		cp.id = point.id;
		//cp.state = ContactState.e_contactAdded;

		++melee.pointCount;
	}

	void persist(bzContactPoint point)
	{
		if (melee.pointCount == k_maxContactPoints) {
			return;
		}

		ContactPoint *cp = &melee.points[melee.pointCount];
		cp.shape1 = point.shape1;
		cp.shape2 = point.shape2;
		cp.position = point.position;
		cp.normal = point.normal;
		cp.id = point.id;
		//cp.state = ContactState.e_contactPersisted;

		++melee.pointCount;
	}

	void remove(bzContactPoint point)
	{
		if (melee.pointCount == k_maxContactPoints) {
			return;
		}

		ContactPoint *cp = &melee.points[melee.pointCount];
		cp.shape1 = point.shape1;
		cp.shape2 = point.shape2;
		cp.position = point.position;
		cp.normal = point.normal;
		cp.id = point.id;
		//cp.state = ContactState.e_contactRemoved;

		++melee.pointCount;
	}

	void result(bzContactResult point) {}

}
