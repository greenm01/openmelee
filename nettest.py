#!/usr/bin/env python2.6
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
from subprocess import Popen
from time import sleep

#g1 = Popen("python -O melee.py :8888 8889 50,0", shell=True)
#g2 = Popen("python -O melee.py :8889 8888 900,0", shell=True)
#mon = Popen("gnome-terminal --geometry=80x25-0-0 --command='netcat -ulp 8889'", shell=True)

# Run subprocesses WITHOUT A SHELL - otherwise we can't kill them!
procs = [
    Popen("python -O melee.py :8888 8889 50,0".split()),
    Popen("python -O melee.py :8889 8888 900,0".split()),
    #Popen(["xterm", "-geometry", "80x25-0-0", "-e", "netcat -ulp 8889"]),
]

print "Spawned PIDs %s" % ([p.pid for p in procs],)

def running():
    for p in procs:
        if p.poll() is not None:
            return False
    return True

while running():
    sleep(0.1)

for p in procs:
    if p.poll() is None:
        print "Killing %d" % p.pid
        p.terminate()
    else:
        print "User killed %d" % p.pid
