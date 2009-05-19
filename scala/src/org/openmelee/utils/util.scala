/*
 * util.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils

import org.villane.vecmath.Vector2f

object Util {

    @inline def rotateLeft90(v:Vector2f) = new Vector2f( -v.y, v.x )

    @inline def rotateRight90(v:Vector2f) = new Vector2f(v.y, -v.x )

    @inline def rotate(v:Vector2f, angle:Float) = {
        val cos = Math.cos(angle).asInstanceOf[Float]
        val sin = Math.sin(angle).asInstanceOf[Float]
        val u = new Vector2f((cos * v.x) - (sin * v.y), (cos * v.y) + (sin * v.x))
        u
    }

}
