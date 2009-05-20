/*
 * Game.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee

import java.awt.event.WindowAdapter
import java.awt.event.WindowEvent

import org.openmelee.melee.Melee
import org.openmelee.render.Render

class Game {

    def init() = {

        val melee = new Melee
        val frame = new javax.swing.JFrame("OpenMelee")
        
        frame.addWindowListener(new WindowAdapter() {
            override def windowClosing(e:WindowEvent) {
                frame.setVisible(false)
                exit()
            }
        })

        frame.setSize(640,480)
        val applet = melee
        frame.getContentPane().add(applet)
        applet.init
        frame.pack
        frame.setVisible(true)
    }

}
