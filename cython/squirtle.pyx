"""Squirtle mini-library for SVG rendering
Example usage:
    import squirtle
    my_svg = squirtle.SVG('filename.svg')
    my_svg.draw(100, 200, angle=15)
"""

include "../include/gl.pxd"

from xml.etree.cElementTree import parse
import re
import math
import sys

cdef GLUtesselator *tess "new GLUtesselator" ()
tess = gluNewTess()
gluTessNormal(tess, 0, 0, 1)
gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO)

def setup_gl():
    """Set various pieces of OpenGL state for better rendering of SVG."""
    glEnable(GL_LINE_SMOOTH)
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

def draw(self, x, y, z=0, angle=0, scale=1, disp_list):
    """Draws the SVG to screen.
    
    :Parameters
        `x` : float
            The x-coordinate at which to draw.
        `y` : float
            The y-coordinate at which to draw.
        `z` : float
            The z-coordinate at which to draw. Defaults to 0. Note that z-ordering may not 
            give expected results when transparency is used.
        `angle` : float
            The angle by which the image should be rotated (in degrees). Defaults to 0.
        `scale` : float
            The amount by which the image should be scaled, either as a float, or a tuple 
            of two floats (xscale, yscale).
    
    """
    glPushMatrix()
    glTranslatef(x, y, z)
    if angle:
        glRotatef(angle, 0, 0, 1)
    if scale != 1:
        try:
            glScalef(scale[0], scale[1], 1)
        except TypeError:
            glScalef(scale, scale, 1)
    #if self._a_x or self._a_y:  
    #    glTranslatef(-self._a_x, -self._a_y, 0)
    glCallList(disp_list)
    glPopMatrix()

    
def triangulate(self, looplist):
    tlist = []
    self.curr_shape = []
    spareverts = []
    '''
    @set_tess_callback(GLU_TESS_VERTEX)
    def vertexCallback(vertex):
        vertex = cast(vertex, POINTER(GLdouble))
        self.curr_shape.append(list(vertex[0:2]))

    @set_tess_callback(GLU_TESS_BEGIN)
    def beginCallback(which):
        self.tess_style = which

    @set_tess_callback(GLU_TESS_END)
    def endCallback():
        if self.tess_style == GL_TRIANGLE_FAN:
            c = self.curr_shape.pop(0)
            p1 = self.curr_shape.pop(0)
            while self.curr_shape:
                p2 = self.curr_shape.pop(0)
                tlist.extend([c, p1, p2])
                p1 = p2
        elif self.tess_style == GL_TRIANGLE_STRIP:
            p1 = self.curr_shape.pop(0)
            p2 = self.curr_shape.pop(0)
            while self.curr_shape:
                p3 = self.curr_shape.pop(0)
                tlist.extend([p1, p2, p3])
                p1 = p2
                p2 = p3
        elif self.tess_style == GL_TRIANGLES:
            tlist.extend(self.curr_shape)
        else:
            self.warn("Unrecognised tesselation style: %d" % (self.tess_style,))
        self.tess_style = None
        self.curr_shape = []

    @set_tess_callback(GLU_TESS_ERROR)
    def errorCallback(code):
        ptr = gluErrorString(code)
        err = ''
        idx = 0
        while ptr[idx]: 
            err += chr(ptr[idx])
            idx += 1
        self.warn("GLU Tesselation Error: " + err)

    @set_tess_callback(GLU_TESS_COMBINE)
    def combineCallback(coords, vertex_data, weights, dataOut):
        x, y, z = coords[0:3]
        data = (GLdouble * 3)(x, y, z)
        dataOut[0] = cast(pointer(data), POINTER(GLvoid))
        spareverts.append(data)
    '''
    data_lists = []
    for vlist in looplist:
        d_list = []
        for x, y in vlist:
            v_data = (GLdouble * 3)(x, y, 0)
            d_list.append(v_data)
        data_lists.append(d_list)
    gluTessBeginPolygon(tess, None)
    for d_list in data_lists:    
        gluTessBeginContour(tess)
        for v_data in d_list:
            gluTessVertex(tess, v_data, v_data)
        gluTessEndContour(tess)
    gluTessEndPolygon(tess)
    return tlist