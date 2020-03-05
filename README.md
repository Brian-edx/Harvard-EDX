# Pong - Assignment 0

This is my first CS50 "Introduction to Game Development" assignment, and first use of Love2D and Lua.

I found a few glitches when I first downloaded the assignment files and installed Love2D:
* In push.lua line 101 I had to update the name of the method called to "love.window.getDPIScale()".  This relates to my use of Love2D version 11, as I discovered from an online search.
* The game then ran, but rendered completely white-on-white, apart from the green FPS display.  I changed the paddle and ball colours so they became visible, then altered line 328 in main.lua to set the background colour using love.graphics.setBackgroundColor().  This fixed the appearance.
