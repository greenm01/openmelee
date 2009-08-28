/*
 * filter.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.objects

import org.villane.box2d.dynamics.{ContactFilter, Fixture}

class Filter extends ContactFilter {
  
  override def shouldCollide(fixture1: Fixture, fixture2: Fixture): Boolean = {
    true
  }

}
