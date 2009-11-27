#
# Copyright (c) 2009 Mason Green & Tom Novelli
#
# This file is part of OpenMelee.
#
# OpenMelee is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMelee is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>.
#
from sys import float_info

from actors.actor import Actor

class SecondaryWeapon(Actor):
    
    # Debug draw colors 
    fill = 255, 0, 0
    outline = 255, 0, 0
    group = 0
    
    health = float_info.max
    
    def __init__(self, mother_ship, melee, body, svg = None):
        self.body = body
        Actor.__init__(self, melee)
        self.mother_ship = mother_ship
        self.group = mother_ship.group
        self.svg = svg
        
        # Register shapes for collision callbacks
        for s in self.body.shapes:
            melee.contact_register[hash(s)] = self
    
    def debug_draw(self):
        if self.svg:
            pos = self.body.position
            self.svg.render(pos.x, pos.y, angle = self.body.angle)
        #Actor.debug_draw(self)