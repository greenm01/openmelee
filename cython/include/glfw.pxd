# GLFW Declarations
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
# along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>.

cdef extern from "GL/glfw.h":

    ctypedef enum:
        GLFW_WINDOW
        GLFW_FULLSCREEN
        GLFW_STICKY_KEYS
        GLFW_OPENED
        GLFW_KEY_ESC 
    
    void glfwSetWindowTitle(char *title)
    
    int GLFW_PRESS
        
    int glfwInit()
    void glfwTerminate()
    int glfwOpenWindow( int width, int height,
            int redbits, int greenbits, int bluebits, int alphabits,
            int depthbits, int stencilbits, int mode )
    void glfwSwapInterval( int interval )
    void glfwSwapBuffers()
    void glfwEnable( int token )
    int  glfwGetWindowParam( int param )
    int  glfwGetKey( int key )
    int  glfwGetWindowParam( int param )
    void glfwGetWindowSize( int *width, int *height )
    double glfwGetTime()
    void glfwSetTime(double time)
    