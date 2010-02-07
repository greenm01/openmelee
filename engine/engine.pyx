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

##
## GL convenience layer
##
from math import pi as PI

from gl cimport *
include "polydecomp.pxi"
include "seidel.pxi"

cdef extern from 'math.h':
    double cos(double)
    double sin(double)
    double sqrt(double)

SEGMENTS = 25
INCREMENT = 2.0 * PI / SEGMENTS
    
def init_gl(width, height):
    #glEnable(GL_LINE_SMOOTH)
    #glEnable(GL_POLYGON_SMOOTH)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glEnable(GL_BLEND)
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glHint (GL_LINE_SMOOTH_HINT, GL_NICEST)
    glEnable(GL_MULTISAMPLE)
    
def reset_zoom(zoom, center, size):

    left = -size[0] / zoom
    right = size[0] / zoom
    bottom = -size[1] / zoom
    top = size[1] / zoom
    
    # Reset viewport
    glLoadIdentity()
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    
    # Reset ortho view
    glOrtho(left, right, bottom, top, 1, -1)
    glTranslatef(-center[0], -center[1], 0)
    glMatrixMode(GL_MODELVIEW)
    glDisable(GL_DEPTH_TEST)
    glLoadIdentity()
    
    # Clear the screen
    glClear(GL_COLOR_BUFFER_BIT)
    
def draw_polygon(verts, color):
    glPointSize(1.1)
    glLineWidth(1.1)
    r, g, b = color
    glColor3f(r, g, b)
    glBegin(GL_LINE_LOOP)
    for v in verts:
        glVertex2f(v[0], v[1])
    glEnd()
       
def draw_test():
    glBegin(GL_TRIANGLES )
    glColor3f(1.0, 0.0, 0.0)
    glVertex2f(0.0, 50.0)
    glColor3f(0.0, 1.0, 0.0)
    glVertex2f(-50.0, -50.0)
    glColor3f(0.0, 0.0, 1.0)
    glVertex2f(50.0, -50.0)
    glEnd()
    glFlush()

def draw_circle(center, radius, outline):

    c = cos(INCREMENT)
    s = sin(INCREMENT)
 
    points = []
    x = radius
    y = 0
 
    cx, cy = center
    for i in range(SEGMENTS ):
        points += [[x + cx, y + cy]]
        t = x
        x = c * x - s * y
        y = s * t + c * y
    
    glColor3ub(outline[0], outline[1], outline[2])
    glBegin(GL_LINE_LOOP)
    for p in points:
        glVertex2f(p[0], p[1])
    glEnd()
    
        
def draw_solid_circle(center, radius, fill, outline):
   
    r, g, b = fill
    r *= 0.5
    g *= 0.5
    b *= 0.5
    
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glColor4ub(int(r), int(g), int(b), 130)
    
    c = cos(INCREMENT)
    s = sin(INCREMENT)
 
    points = []
    x = radius
    y = 0
 
    cx, cy = center
    for i in range(SEGMENTS ):
        points += [[x + cx, y + cy]]
        t = x
        x = c * x - s * y
        y = s * t + c * y
        
    glBegin(GL_TRIANGLE_FAN)
    for p in points:
        glVertex2f(p[0], p[1])
    glEnd()
    glDisable(GL_BLEND)
 
    glColor3ub(outline[0], outline[1], outline[2])
    glBegin(GL_LINE_LOOP)
    for p in points:
        glVertex2f(p[0], p[1])
    glEnd()

def draw_solid_polygon(vertices, fill, outline):
    
    r, g, b = fill
    r *= 0.5
    g *= 0.5
    b *= 0.5
    
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glColor4ub(int(r), int(g), int(b), 130)
    
    glBegin(GL_TRIANGLE_FAN)
    for v in vertices:
        glVertex2f(v[0], v[1])
    glEnd()
    glDisable(GL_BLEND)

    glColor3ub(outline[0], outline[1], outline[2])
    glBegin(GL_LINE_LOOP)
    for v in vertices:
        glVertex2f(v[0], v[1])
    glEnd()

def draw_line(x1, y1, x2, y2):
    glColor3ub(255, 255, 0)
    glBegin(GL_LINES)
    glVertex2f(x1, y1)
    glVertex2f(x2, y2)
    glEnd()

##
## Game engine / main loop / UI
##
from glfw cimport *

import sys

# Keyboard callback wrapper
kbd_callback_method = None

cdef extern void __stdcall kbd_callback(int id, int state):
    kbd_callback_method(id, state)

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

    def register_kbd_callback(self, f):
        global kbd_callback_method
        glfwSetKeyCallback(kbd_callback)
        kbd_callback_method = f

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
             
            self.update()
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

def render_fast(paths, gradients, translate, scale):
    disp_list = glGenLists(1)
    glNewList(disp_list, GL_COMPILE)
    cdef int n_lines = 0
    for path, stroke, fill, transform in paths:
        for loop in path:
              '''
              n_lines += len(loop) - 1
              if stroke:
                  loop_plus = []
                  for i in xrange(len(loop) - 1):
                      loop_plus += [loop[i], loop[i+1]]
                  if isinstance(stroke, str):
                      g = gradients[stroke]
                      clrs = [g.interp(x) for x in loop_plus]
                  else:
                      clrs = [stroke for x in loop_plus]
              else:
                  if isinstance(fill, str):
                      g = gradients[fill]
                      clrs = [g.interp(x) for x in loop]
                  else:
                      clrs = [fill for x in loop]
              '''  
              '''
              glBegin(GL_LINES)
              for vtx, clr in zip(loop_plus, strokes):
                  vtx = transform(vtx)
                  r, g, b, a = clr
                  glColor4ub(r, g, b, a)
                  x = (vtx[0] - translate[0]) * scale
                  y = (vtx[1] - translate[1]) * scale
                  glVertex2f(x, y)
              glEnd()
              '''
              strokes = []
              #Draw to stencil
              glDisable (GL_BLEND)
              glEnable (GL_STENCIL_TEST)
              glStencilMask (0x01)
              glStencilOp (GL_KEEP, GL_KEEP, GL_INVERT)
              glStencilFunc (GL_ALWAYS, 0, ~0)
              glColorMask (GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE)

              glBegin (GL_TRIANGLE_FAN)
              for vtx in loop:
                  vtx = transform(vtx)
                  #r, g, b, a = clr
                  #glColor4ub(r, g, b, a)
                  x = (vtx[0] - translate[0]) * scale
                  y = (vtx[1] - translate[1]) * scale
                  glVertex2f(x, y)
              glEnd ();
              
              # Draw aliased off-pixels to real
              glColorMask (GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE)
              glEnable (GL_BLEND)
              glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

              glStencilFunc (GL_EQUAL, 0x00, 0x01)
              glStencilOp (GL_KEEP, GL_KEEP, GL_KEEP)
              
              glEnable(GL_LINE_SMOOTH)
              glBegin (GL_LINE_LOOP)
              for vtx in loop:
                  vtx = transform(vtx)
                  #r, g, b, a = clr
                  #glColor4ub(r, g, b, a)
                  glColor4f(1.0, 0.0, 0.0, 0.5)
                  x = (vtx[0] - translate[0]) * scale
                  y = (vtx[1] - translate[1]) * scale
                  glVertex2f(x, y)
              glEnd ()
              glDisable (GL_LINE_SMOOTH)

              # Draw fill
              glStencilFunc (GL_EQUAL, 0x01, 0x01)
              glStencilOp (GL_ZERO, GL_ZERO, GL_ZERO)

              glBegin (GL_POLYGON)
              for vtx in loop:
                  vtx = transform(vtx)
                  #r, g, b, a = clr
                  #glColor4ub(r, g, b, a)
                  x = (vtx[0] - translate[0]) * scale
                  y = (vtx[1] - translate[1]) * scale
                  glVertex2f(x, y)
              glEnd ()

              glDisable (GL_STENCIL_TEST)
    
    glEndList()
    return disp_list
    
def render_display_list(paths, gradients, translate, scale):
    disp_list = glGenLists(1)
    glNewList(disp_list, GL_COMPILE)
    cdef int n_tris = 0
    cdef int n_lines = 0
    for path, stroke, tris, fill, transform in paths:
        if tris:
            n_tris += len(tris)/3
            if isinstance(fill, str):
                g = gradients[fill]
                fills = [g.interp(x) for x in tris]
            else:
                fills = [fill for x in tris]
            glBegin(GL_TRIANGLES)
            for vtx, clr in zip(tris, fills):
                vtx = transform(vtx)
                r, g, b, a = clr
                glColor4ub(r, g, b, a)
                x = (vtx[0] - translate[0]) * scale
                y = (vtx[1] - translate[1]) * scale
                glVertex2f(x, y)
            glEnd()
        if path:
            for loop in path:
                n_lines += len(loop) - 1
                loop_plus = []
                for i in xrange(len(loop) - 1):
                    loop_plus += [loop[i], loop[i+1]]
                if isinstance(stroke, str):
                    g = gradients[stroke]
                    strokes = [g.interp(x) for x in loop_plus]
                else:
                    strokes = [stroke for x in loop_plus]
                glBegin(GL_LINES)
                for vtx, clr in zip(loop_plus, strokes):
                    vtx = transform(vtx)
                    r, g, b, a = clr
                    glColor4ub(r, g, b, a)
                    x = (vtx[0] - translate[0]) * scale
                    y = (vtx[1] - translate[1]) * scale
                    glVertex2f(x, y)
                glEnd() 
    glEndList()
    return disp_list
    
def render_list(x, y, z, angle, scale, disp_list):
    glPushMatrix()
    glTranslatef(x, y, z)
    glRotatef(angle*57.29578+180, 0, 0, 1)
    if scale != 1:
        try:
            glScalef(scale[0], scale[1], 1)
        except TypeError:
            glScalef(scale, scale, 1)
    #if self._a_x or self._a_y:  
    #    glTranslatef(-self._a_x, -self._a_y, 0)
    glCallList(disp_list)
    glPopMatrix()

