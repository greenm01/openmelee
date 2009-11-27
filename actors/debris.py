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

class Debris(Actor):

    # Debug draw colors 
    fill = 205, 201, 201
    outline = 0, 0, 255
    group = 3
    
    def __init__(self, melee, body):
        self.body = body
        Actor.__init__(self, melee)
        
        # Register shapes for collision callbacks
        for s in self.body.shapes:
            melee.contact_register[hash(s)] = self
            
    def apply_gravity(self):
        pass