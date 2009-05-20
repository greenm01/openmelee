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

import processing.core.PApplet
import processing.core.PConstants

import render.Render
import objects.ships.Orz
import ai.Human

class Melee extends PApplet {

    val min = new Vector2f(-200f, -100f)
	val max = new Vector2f(200f, 200f)
	val worldAABB = new AABB(min, max)
	val gravity = new Vector2f(0f, 0f)
	val world = new World(worldAABB, gravity, false)
    val orz = new Orz(this)
    val human = new Human(orz, this)
    val render = new Render(this)

    val timeStep = 1f/60f
    val iterations = 10

    def go = PApplet.main(Array("org.openmelee.melee.Melee"))
    
    override def setup() {
        width = 640
        height = 480
		val targetFPS = 60
		size(width, height, PConstants.P3D)
		frameRate(targetFPS)
        for (i <- 0 until 100) {
    		requestFocus
    	}
        frame.setTitle("OpenMelee")
	}

    // Main processing loop
	override def draw() {
		background(0xFAF0E6)
        orz.updateState()
        world.step(timeStep, iterations)
        render update world

	}

    override def keyPressed() {
        human.onKeyDown(keyCode)
    }

    override def keyReleased() {
        human.onKeyUp(keyCode)
    }
    
}