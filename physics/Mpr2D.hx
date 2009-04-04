/*
 * Copyright (c) 2009, Mason Green 
 * http://github.com/zzzzrrr/haxmel
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the polygonal nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package mpr2d;

import tango.stdc.stringz;
import tango.math.Math;

import derelict.opengl.gl;
import derelict.opengl.glu;
import derelict.sdl.sdl;

import System;
import Vector2D;

const char[] WINDOW_TITLE = "MPR2D";

//The screen attributes
const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 600;
const int SCREEN_BPP = 32;

RigidSys system;

// The main loop flag
bool running;
// Draw closest features
bool closestFeatures;
// Draw closest points
bool closestPoints = true;

//Module constructor.
static this()
{
    // Load Derelict OpenGL libraries
    DerelictGL.load();
    DerelictGLU.load();
    DerelictSDL.load();

    if (SDL_Init(SDL_INIT_VIDEO) < 0)
        throw new Exception("Failed to initialize SDL: " ~ getSDLError());
}

// Module destructor
static ~this()
{
    SDL_Quit();
}

void main(char[][] args)
{
    bool fullScreen = false;
    system = new RigidSys(2);

    if (args.length > 1) fullScreen = args[1] == "-fullscreen";

    createGLWindow(WINDOW_TITLE, SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_BPP, fullScreen);
    initGL();

    running = true;
    // Main Program Loop
    while (running)
    {
        // User input
        processEvents();
        // Update Rigid Bodies
        system.update();
        // Draw Scene
        drawScene();
        // SDL Maintenance
        SDL_GL_SwapBuffers();
    }
}

void processEvents()
{
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
        switch (event.type)
        {
        case SDL_KEYUP:
            keyReleased(event.key.keysym.sym);
            break;
        case SDL_QUIT:
            running = false;
            break;
        default:
            break;
        }
    }
}

// Controls
void keyReleased(int key)
{
    switch (key)
    {
    case SDLK_1:
        closestFeatures = !closestFeatures;
        break;
    case SDLK_2:
        closestPoints = !closestPoints;
        break;
    case SDLK_ESCAPE:
        running = false;
        break;
    case SDLK_RIGHT:
        system.rb[1].vel.x += 5;
        break;
    case SDLK_LEFT:
        system.rb[1].vel.x -= 5;
        break;
    case SDLK_UP:
        system.rb[1].vel.y += 5;
        break;
    case SDLK_DOWN:
        system.rb[1].vel.y -= 5;
        break;
    case SDLK_SPACE:
        system.rb[1].vel.x = 0;
        system.rb[1].vel.y = 0;
        system.rb[1].omega = 0;
        break;
    case SDLK_RSHIFT:
        system.rb[1].omega += 0.01;
        break;
    case SDLK_RETURN:
        system.rb[1].omega -= 0.01;
        break;
    case SDLK_d:
        system.rb[0].vel.x += 5;
        break;
    case SDLK_a:
        system.rb[0].vel.x -= 5;
        break;
    case SDLK_w:
        system.rb[0].vel.y += 5;
        break;
    case SDLK_s:
        system.rb[0].vel.y -= 5;
        break;
    case SDLK_e:
        system.rb[0].omega += 0.01;
        break;
    case SDLK_q:
        system.rb[0].omega -= 0.01;
        break;
    case SDLK_c:
        system.rb[0].vel.x = 0;
        system.rb[0].vel.y = 0;
        system.rb[0].omega = 0;
        break;
    case SDLK_p:
        system.rb[0].q = 0;
        system.rb[1].q = 0;
        break;
    case SDLK_LEFTBRACKET:
        if (system.shape1 == 5) system.shape1 = 1;
        else if(system.shape1 == 4) system.shape1 = 5;
        else system.shape1++;
        system.spawn(1);
        break;
    case SDLK_RIGHTBRACKET:
        if (system.shape2 == 5) system.shape2 = 1;
        else if(system.shape2 == 4) system.shape2 = 5;
        else system.shape2++;
        system.spawn(2);
        break;
    default:
        break;
    }
}

void initGL()
{
    glLoadIdentity();

    glMatrixMode( GL_PROJECTION );
    // Use 2d Coordinate system
    gluOrtho2D(0,100,0,100);
    glMatrixMode( GL_MODELVIEW );
    glDisable(GL_DEPTH_TEST);

    glShadeModel(GL_SMOOTH);
    // Black Background
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glLoadIdentity();
}

void drawScene()
{
    // Clear The Screen And The Depth Buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();

    glColor3f(0,0,1);	// Blue
    glLineWidth(2);

    // Draw center Bullseye
    glBegin(GL_LINES);
    {
        glVertex2d(50,52.5);
        glVertex2d(50,47.5);
        glVertex2d(47.5,50);
        glVertex2d(52.5,50);
    }
    glEnd();

    glColor3f(1,0,0);	// Red

    // Draw Polygon
    foreach(int i, RigidBody b; system.rb)
    {
        if (i == 1) glColor3f(0,1,0); // Green

        if(b.type == 5)
        {
            glBegin(GL_LINE_STRIP);
            {
                foreach(v; b.vertex)
                    glVertex2d(v.x, v.y);
                glVertex2f(b.pos.x,b.pos.y);
            }
            glEnd();
        }
        else
        {
            glBegin(GL_LINE_LOOP);
            {
                foreach(v; b.vertex)
                    glVertex2d(v.x, v.y);
            }
            glEnd();
            glLoadIdentity();
        }
    }

    glTranslatef(50,50,0);

    if (system.penetrate == false)
        glColor3f(1.0, 1.0, 1.0); // White - No contact
    else glColor3f(0, 0, 1);      // Blue - Hit

    // Draw Minkowski Hull
    glBegin(GL_LINE_STRIP);
    {
        int k = 0;
        foreach(Vector m; system.minkHull)
        if (m.x != 0 && m.y != 0)
        {
            glVertex2d(m.x, m.y);
            k++;
        }
    }
    glEnd();

    // Draw contact points
    if (system.penetrate)
    {
        glLoadIdentity();
        glTranslatef(50,50,0);
        // Yellow
        glColor3f(1,1,0);

        glBegin(GL_POINTS);
        {
            glVertex2d(system.returnNormal.x, system.returnNormal.y);
        }
        glEnd();

        glLoadIdentity();

        glPointSize(10);

        glBegin(GL_POINTS);
        {
            if(closestFeatures)
            {
                glColor3f(1,0,0); // Red
                foreach(v; system.sA)
                    glVertex2d(v.x, v.y);

                glColor3f(0,1,0);  // Green
                foreach(v; system.sB)
                    glVertex2d(v.x, v.y);
            }

            if(closestPoints)
            {

                glColor3f(1,0,0);   // Red
                glVertex2d(system.point1.x, system.point1.y);

                glColor3f(0,1,0);   // Green
                glVertex2d(system.point2.x, system.point2.y);
            }
        }
        glEnd();
    }

    // Draw simplex (CSO)

    glLoadIdentity();
    glTranslatef(50,50,0);
    // Yellow
    glColor3f(1,1,0);

    glBegin(GL_LINE_LOOP);
    {
        foreach(v; system.sAB)
            glVertex2d(v.x, v.y);
    }
    glEnd();

}

void createGLWindow(char[] title, int width, int height, int bits, bool fullScreen)
{
    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 6);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    SDL_WM_SetCaption(toStringz(title), null);

    int mode = SDL_OPENGL;
    if (fullScreen) mode |= SDL_FULLSCREEN;

    if (SDL_SetVideoMode(width, height, bits, mode) is null)
    {
        throw new Exception("Failed to open OpenGL window: " ~ getSDLError());
    }
}

char[] getSDLError()
{
    return fromStringz(SDL_GetError());
}
