'''
Copyright 2009 Mason Green & Tom Novelli

This file is part of OpenMelee.

OpenMelee is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

OpenMelee is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenMelee.  If not, see <http://www.gnu.org/licenses/>.
'''
import os
import pygame
import players.kbd_sdl as kbd

from utils import transform

BLACK = 0, 0, 0, 0
WHITE = 255,255,255

class Window:
    "A Pygame/SDL interface in the style of Pyglet"
    backend = 'sdl'

    def __init__(self):
        # Initialize Pygame/SDL
        os.environ['SDL_VIDEO_WINDOW_POS'] = self.WINDOW_POSITION
        pygame.init()
        self.screen = pygame.display.set_mode((self.sizeX, self.sizeY))

        '''
        if sys.hexversion >= 0x2060000:
            import warnings
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                # Next statement gives this warning... no big deal...
                # sysfont.py:139: DeprecationWarning: os.popen3 is deprecated.  Use the subprocess module.
            self.font = pygame.font.SysFont("", 24)
        '''
        self.font = pygame.font.SysFont("", 24)

        print "Pygame (SDL) backend"
        print "  Timer resolution: %dms" % pygame.TIMER_RESOLUTION
        try:
            print "  Using %s smoothscale backend." % pygame.transform.get_smoothscale_backend()
        except AttributeError:
            pass

        transform.set_screen(self.screen)
        self.clock = pygame.time.Clock()

    def set_caption(self, caption):
        pygame.display.set_caption(caption)

    def get_time_ms(self):
        return pygame.time.get_ticks()

    def on_draw(self):
        self.screen.fill(BLACK)

        view = self.calculate_view()
        zoom, view_center = view
        transform.set_view(view)

        # Display debug info
        if self.net:
            s = "player=%d rtt=%s tdiff=%s" % (
                    self.local_player,
                    self.net.rtt_avg,
                    self.net.tdiff_avg,
            )
            surf = self.font.render(s, False, WHITE)
            self.screen.blit(surf, (0,20))

        s = "fps=%3d zoom=%3.3f center=%5d,%5d" % (
                self.clock.get_fps(),
                zoom,
                view_center[0], view_center[1],
        )
        surf = self.font.render(s, False, WHITE)
        self.screen.blit(surf, (0,0))

        # Common to SDL and GL renderers:
        self.planet.draw(self.screen, view)

        for s in self.actors:
            if s:
                s.draw(self.screen, view)

        # Draw lines between objects (DEBUG)
        '''
        a = transform.to_sdl(self.planet.body.position)
        for ship in self.actors:
            b = transform.to_sdl(ship.body.position)
            pygame.draw.line(self.screen, (0,0,255), a, b)
        '''

        # Draw world bounding box
        c = 90, 230, 230
        ub = self.aabb.upper_bound
        lb = self.aabb.lower_bound 
        x1,y1 = transform.to_sdl((lb.x, lb.y))
        x2,y2 = transform.to_sdl((ub.x, ub.y))
        pygame.draw.rect(self.screen, c, pygame.Rect(x1, y1, x2-x1, y2-y1), 2)

        # End of frame
        pygame.display.update()
        self.clock.tick(self.frame_rate)

    def mainloop(self):
        while 1:
            if kbd.process_events(self):
                return
            if self.net:
                self.net.process_events(self)
            self.update()
            self.on_draw()
