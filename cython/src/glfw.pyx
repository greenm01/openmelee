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

include "../include/glfw.pxd"

import sys

cdef extern from 'math.h':
    double cos(double)
    double sin(double)
    double sqrt(double)

key_id = 0
key_state = 0

cdef extern void __stdcall callback(int id, int state):
    global key_id, key_state
    key_id = id
    key_state = state
    
cdef class Game:

    title = "OpenMelee 0.01"
    
    def __init__(self, window_width, window_height):
    
        glfwInit()
        
        # 16 bit color, no depth, alpha or stencil buffers, windowed
        if not glfwOpenWindow(window_width, window_height, 8, 8, 8, 8, 24, 0, GLFW_WINDOW):
            glfwTerminate()
            raise SystemError('Unable to create GLFW window')
        
        glfwEnable(GLFW_STICKY_KEYS)
        glfwSwapInterval(1) #VSync on
        # Set key callback            
        glfwSetKeyCallback(callback)

    def main_loop(self):
        
        frame_count = 1
        start_time = glfwGetTime()

        running = True
        while running:
            
            current_time = glfwGetTime()
            
            #Calculate and display FPS (frames per second)
            if (current_time - start_time) > 1 or frame_count == 0:
                frame_rate = frame_count / (current_time - start_time)
                t = self.title + " (%d FPS)" % frame_rate
                glfwSetWindowTitle(t)
                start_time = current_time
                frame_count = 0
                
            frame_count = frame_count + 1

            # Check if the ESC key was pressed or the window was closed
            running = ((not glfwGetKey(GLFW_KEY_ESC))
                       and glfwGetWindowParam(GLFW_OPENED))
             
            self.update(key_id, key_state)
            self.render()
        
            glfwSwapBuffers()

            
        glfwTerminate()
        
    property window_title:
        def __set__(self, title): self.title = title
        
    property time:
        def __get__(self): return glfwGetTime()
        def __set__(self, t): glfwSetTime(t)
        
# TODO: Refactor math functions into a math module  
     
def vforangle(angle):
    return (cos(angle), sin(angle))
    
def rotate(v1, v2):
    return (v1[0]*v2[0] - v1[1]*v2[1], v1[0]*v2[1] + v1[1]*v2[0])

# TODO develop a better gravity attractor?
def calc_planet_gravity(float px, float py):

    min_radius = 1
    max_radius = 20
    strength = 500
 
    center = 0, 0
    rx = center[0] - px
    ry = center[1] - py
    d = sqrt(rx * rx + ry * ry)
    rx /= d
    ry /= d
    ratio = (d - min_radius) / (max_radius - min_radius)
    
    if ratio < 0.0:
        ratio = 0.0
    elif ratio > 1.0:
        ratio = 1.0
    
    return (rx * ratio * strength, ry * ratio * strength)
    
