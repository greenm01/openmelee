package org.openmelee

import scala.Application

object Main extends Application {

	override def main(args: Array[String]) = {
        val game = new Game
        game init
	}
}

