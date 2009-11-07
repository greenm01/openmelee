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
from actors.actor import Actor

class PrimaryWeapon(Actor):
    
    # Debug draw colors 
    fill = 255, 0, 0
    outline = 255, 0, 0
    
    def __init__(self, mother_ship, melee, body):
        self.body = body
        Actor.__init__(self, melee)
        self.mother_ship = mother_ship
        
        # Register shapes for collision callbacks
        for s in self.body.shapes:
            melee.contact_register[hash(s)] = self
       
    