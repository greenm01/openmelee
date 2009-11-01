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
import pygame
from pygame.locals import *
import socket
import struct

class NetConn:
    # Packet codes
    HANDSHAKE = 1
    INITIALIZE = 2
    SYNCHRONIZE = 3
    PING = 6
    ACK = 7
    UPDATE = 8
    DELTA = 9

    HDR_FMT = "!BLL"   # code, seq, time
    HDR_LEN = struct.calcsize(HDR_FMT)

    MAX_SIZE = 256

    def __init__(self, local, remote, melee):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(local)
        self.sock.setblocking(False)
        self.remote = remote
        self.melee = melee
        self.seq = 1
        self.rseq = 1
        self.queue = {}    # seq : time_sent
        self.rtt_avg = None
        self.tdiff_avg = None

    def status(self, t, rest):
        #print "%d %dms %s" % (self.melee.player, t, rest)
        print "%dms %s" % (t, rest)

    def send(self, code, msg):
        if (self.HDR_LEN + len(msg)) > self.MAX_SIZE:
            print "**Packet too long!**"
            #return 0
        seq = self.seq
        t = pygame.time.get_ticks()
        hdr = struct.pack(self.HDR_FMT, code, seq, t)
        self.sock.sendto(hdr+msg, self.remote)
        print "t=%d SEND: %d seq=%d t=%d len=%d msg=%r" % (t, code, seq, t, len(msg), msg)
        self.queue[seq] = t
        self.seq += 1
        return seq

    def pump(self):
        #print self.melee.player
        while 1:
            try:
                data, addr = self.sock.recvfrom(self.MAX_SIZE)
                tr = pygame.time.get_ticks()
                #print "Rcvd from %s: %s" % (addr, data)
                #self.sock.sendto(b"echo: "+data, addr)
                hdr = data[:self.HDR_LEN]
                msg = data[self.HDR_LEN:]
                code, seq, t = struct.unpack(self.HDR_FMT, hdr)

                if code != self.ACK:
                    # Acknowledge all packets except ACKs
                    self.status(tr, "RCVD %d seq=%d t=%d msg=%r" % (code, seq, t, msg))
                    self.send(self.ACK, struct.pack("!L", seq))
                    #print "Sent ACK %d" % seq
                    yield code, t, msg
                else:
                    # When ACK received, compute latency etc.
                    aseq, = struct.unpack("!L", msg)
                    ts = self.queue.pop(aseq, None)
                    if ts is not None:
                        self.status(tr, "RCVD ACK seq=%d RTT=%d Tdiff=%d" % (aseq, tr-ts, t-ts))
                        if self.rtt_avg:
                            self.rtt_avg = (self.rtt_avg + tr-ts) / 2
                            self.tdiff_avg = (self.tdiff_avg + t-ts) / 2
                        else:
                            self.rtt_avg = tr-ts
                            self.tdiff_avg = t-ts
                    else:
                        print "UNEXPECTED ACK %r   ts=%r" % (aseq, ts)
                        print self.queue

            except socket.error:
                return

    def pump_debug(self):
        for e in self.pump():
            self.status(0, "PUMPED %s" % e)

    def handshake(self):
        state = self.melee.serialize()
        seq = self.send(self.HANDSHAKE, state)
        self.status(pygame.time.get_ticks(), "Sent handshake, seq=%d" % seq)
        ## Wait for ack
        for i in range(6):
            self.status(pygame.time.get_ticks(), "Waiting for handshake ACK, seq=%d, queue=%r" % (seq, self.queue))
            self.pump_debug()
            if seq not in self.queue:
                self.status(pygame.time.get_ticks(), "Handshake ACKed")
                break
            pygame.event.pump()
            pygame.time.wait(500)
        else:
            self.status(pygame.time.get_ticks(), "Handshake TIMED OUT waiting for ACK")

        # Wait a bit...
        #pygame.time.wait(100)

        # Measure latency
        for i in range(5):
            self.ping()
            pygame.time.wait(300)

    def wait_handshake(self):
        for i in range(8):
            for code, t, msg in self.pump():
                if code == self.HANDSHAKE:
                    print "Handshake received, ACK sent"
                    return msg
            pygame.event.pump()
            #self.melee.clock.tick(500)
            pygame.time.wait(500)
        else:
            print "TIMED OUT waiting for handshake"
            return None

    def ping(self):
        self.send(self.PING, "")


    def process_events(self, game):
        # Receive
        for e in self.pump():
            #print "t=%d REMOTE %s" % (pygame.time.get_ticks(), e)
            code, t, msg = e
            if code == self.DELTA:
                buttons, = struct.unpack("!B", msg)
                game.actors[game.remote_player].buttons = buttons
                self.status(t, "buttons = %s" % buttons)

        # Send   TODO(tom) event queuing
        if game.button_change:
            buttons = game.actors[game.local_player].buttons
            msg = struct.pack("!B", buttons)
            self.send(self.DELTA, msg)

            game.button_change = False



class NetPlayer: pass
