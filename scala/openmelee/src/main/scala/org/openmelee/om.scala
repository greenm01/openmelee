/*
 * Game.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package org.openmelee

import org.newdawn.slick.AppGameContainer
import org.newdawn.slick.state.StateBasedGame
import org.newdawn.slick.GameContainer

import melee.Melee

object OpenMelee {

  val game = new Game

	def main(args: Array[String]) {
    game.init()
	}
}

class Game extends StateBasedGame("OpenMelee") {

  val MAINMENUSTATE = 0
  val GAMEPLAYSTATE = 1

  addState(new Melee(GAMEPLAYSTATE))
  enterState(GAMEPLAYSTATE)
   
  def init() {
    val app = new AppGameContainer(this)
    app.setDisplayMode(600, 600, false)
    app.start
  }

  override def initStatesList(gameContainer:GameContainer) {
    getState(GAMEPLAYSTATE).init(gameContainer, this)
  }

}
