import math
from pymunk import Vec2d

# Utility functons. Some of these may eventally be moved

def rotate(v, angle):
    cos = math.cos(angle)
    sin = math.sin(angle)
    return Vec2d((cos * v.x) - (sin * v.y), (cos * v.y) + (sin * v.x))
    
def clamp(a, low, high):
    return max(low, min(a, high)) 	

