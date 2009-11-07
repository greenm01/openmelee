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
from physics import ContactHub

class ContactListener(ContactHub):

    def __init__(self, melee):
        self.melee = melee
        ContactHub.__init__(self, melee.world)
        
    def add(self, p):
        shapes = p.get_shapes(self.melee.world)
        self.melee.collision_callback(*shapes)
        
    def remove(self, p):
        pass