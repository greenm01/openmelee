/*
 * Melee.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.melee

import org.villane.box2d.shapes.AABB
import org.villane.box2d.dynamics.World
import org.villane.vecmath.Vector2f

import org.openmelee.render.Render
import org.openmelee.objects.ships.Orz

class Melee() {

    val width = 640
    val height = 480
    
    val min = new Vector2f(-200f, -100f)
	val max = new Vector2f(200f, 200f)
	val worldAABB = new AABB(min, max)
	val gravity = new Vector2f(0f, 0f)
	val world = new World(worldAABB, gravity, true)
    val orz = new Orz(this)
    val render = new Render(width, height, this)
    
}