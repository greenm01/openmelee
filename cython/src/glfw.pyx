include "../include/glfw.pxd"

import sys

cdef extern from 'math.h':
    double cos(double)
    double sin(double)
    double sqrt(double)
    
cdef class Game:

    title = ""
    
    def __init__(self, window_width, window_height):
    
        glfwInit()
        
        # 16 bit color, no depth, alpha or stencil buffers, windowed
        if not glfwOpenWindow(window_width, window_height, 8, 8, 8, 8, 24, 0, GLFW_WINDOW):
            glfwTerminate()
            raise SystemError('Unable to create GLFW window')
        else:
            glfwEnable(GLFW_STICKY_KEYS)
            glfwSwapInterval(1) #VSync on
        
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
    
def calc_planet_gravity(pos):
    min_radius = 0.1
    max_radius = 30
    strength = 15
 
    center = 0, 0
    rx = center[0] - pos.x
    ry = center[1] - pos.y
    d = sqrt(rx * rx + ry * ry)
    rx /= d
    ry /= d
    ratio = (d - min_radius) / (max_radius - min_radius)
    
    if ratio < 0.0:
        ratio = 0.0
    elif ratio > 1.0:
        ratio = 1.0
    
    return rx * ratio * strength, ry * ratio * strength
    
