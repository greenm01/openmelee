from actors.ships.ship import Ship
from pyglet.window import key

class Human(object):
 
    def __init__(self, ship):
        self.quit = False
        self.turn = False
        self.ship = ship

    def onKeyDown(self, k):
        if k == key.ESCAPE: 
            # Quit
            self.quit = True
        elif k == key.W: 
            # Thrust
            self.ship.engines = True
        elif k == key.A:
            # Left
            if not self.ship.turnL and not self.ship.special:
                self.ship.turn_left()
                self.ship.turnL = True
        elif k == key.D:
            # Right
            if not self.ship.turnR and not self.ship.special:
                self.ship.turn_right()
                self.ship.turnR = True
        elif k == key.PERIOD: 
            # Fire
            self.ship.primary = True
        elif k == key.SLASH:
            # Specal
            self.ship.special = True
        
    def onKeyUp(self, k):
        if k == key.A or k == key.D:
            self.ship.turnR = False
            self.ship.turnL = False
            self.ship.body.angular_velocity = 0
        elif k == key.W:
            self.ship.engines = False
        elif k == key.SLASH:
            self.ship.special = False
        elif k == key.PERIOD:
            self.ship.primary = False
