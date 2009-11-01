'''
Copyright 2009 Mason Green & Tom Novelli

This file is part of OpenMelee.

OpenMelee is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

OpenMelee is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>.
'''
from actors.actor import Actor

class PrimaryWeapon(Actor):

    def __init__(self, mother_ship, melee, body):
        self.body = body
        Actor.__init__(self, melee)
        self.mother_ship = mother_ship
        self.shapes = []
        
    def draw(self, surface, view):
        if self.melee.backend == 'sdl':
            import pygame
            from utils import transform
            fill = 255,0,0
            r = transform.scale(40.0)
            pygame.draw.circle(surface, fill, transform.to_sdl(self.body.position), r)
        elif self.melee.backend == 'gl':
            from render import Color, draw_polygon
            color = Color(1, 0, 0)
            for s in self.shapes:
                draw_polygon(s, color)
