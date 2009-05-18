/*
 * Melee.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.melee

import org.jbox2d.collision.AABB
import org.jbox2d.dynamics.World
import org.jbox2d.common.Vec2

import org.openmelee.render.Render
import org.openmelee.objects.ships.Orz

class Melee() {

    val width = 640
    val height = 480
    
    val min = new Vec2(-200, -100)
	val max = new Vec2(200, 200)
	val worldAABB = new AABB(min, max)
	val gravity = new Vec2(0, -9.81f)
	val world = new World(worldAABB, gravity, true)
    val orz = new Orz(this)
    val render = new Render(width, height, this)
    
}


