/*
 * gameObject.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.objects

import org.villane.box2d.dynamics.Body

abstract class GameObject {
    val body : Body
    //var sprite : PShape
    def updateState()
}
