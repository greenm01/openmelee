#!/usr/bin/env python2.6
from engine import decompose_poly

poly_line = [[0,0],[5,5],[-5,0],[5,-5]]
polygons = []

decompose_poly(poly_line, polygons)