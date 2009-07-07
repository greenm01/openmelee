/*
 * shape.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.openmelee.utils.svg.shapes

import org.villane.vecmath.Vector2

import render.RenderG11

abstract class Shape extends RenderG11 with Properties {
  def render
}
