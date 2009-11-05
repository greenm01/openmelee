#!/usr/bin/env python2.6
#
# Copyright 2009 Mason Green & Tom Novelli
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
# along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>

import sys
import os

from melee import Melee

if __name__ == '__main__':
    '''
    Usage: melee.py [[remote-address]:port] [local-port] [position]
    '''
    REMOTE = None
    LOCAL  = ('', 8888)
    if len(sys.argv) > 1:
        a = sys.argv[1].split(':')
        REMOTE = (a[0], int(a[1]))
    if len(sys.argv) > 2:
        LOCAL = ('', int(sys.argv[2]))
    if len(sys.argv) > 3:
        Melee.WINDOW_POSITION = sys.argv[3]

    window = Melee(REMOTE)
