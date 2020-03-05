# Pong - Assignment 0

This is my first CS50 "Introduction to Game Development" assignment, and first use of Love2D and Lua.

I found a few glitches when I first downloaded the assignment files and installed Love2D:
* In push.lua line 101 I had to update the name of the method called to "love.window.getDPIScale()".  This relates to my use of Love2D version 11, as I discovered from an online search.
* The game then ran, but rendered completely white-on-white, apart from the green FPS display.  I changed the paddle and ball colours so they became visible, then altered line 328 in main.lua to set the background colour using love.graphics.setBackgroundColor().  This fixed the appearance.

I made the following further changes:
* In main.lua added PADDLE_HEIGHT = 20, since I wanted to use this value in my new code.
* In main.lua added TWO_PLAYER_MODE = false, so that the game could be compiled for one or two players.
* Changed love.update() to implement a basic AI mode for player one:

```
    if TWO_PLAYER_MODE the
        -- This is the pre-existing two-player code:
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end
    else
        -- The new AI-powered mode!
        -- Tracks the ball movement so the AI player gets it right every time, as long
        -- as the ball is not moving too fast!
        -- use an offset of 1 to place the ball nearer the centre of the bat.
        if ball.y < player1.y + 1 then
            player1.dy = -PADDLE_SPEED
        elseif ball.y > player1.y + PADDLE_HEIGHT - 1 then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end
    end
```   


