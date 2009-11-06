include "../include/gl.pxd"

from math import pi as PI

cdef extern from 'math.h':
    double cos(double)
    double sin(double)

SEGMENTS = 25
INCREMENT = 2.0 * PI / SEGMENTS
    
def init_gl(width, height):
    #glEnable(GL_LINE_SMOOTH)
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glHint (GL_LINE_SMOOTH_HINT, GL_NICEST)
    
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