/*
 * Game.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee

import org.openmelee.melee.Melee
import org.openmelee.render.Render

class Game {

    val melee = new Melee

    def init() = {
        melee.init()
        melee go
    }

}
