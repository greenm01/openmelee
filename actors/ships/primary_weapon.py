from actors.actor import Actor
from render import Color, draw_polygon

class PrimaryWeapon(Actor):

    def __init__(self, mother_ship, melee, body):
        self.body = body
        Actor.__init__(self, melee)
        self.mother_ship = mother_ship
        self.shapes = []
        
    def draw(self):
        color = Color(1, 0, 0)
        for s in self.shapes:
            draw_polygon(s, color)
