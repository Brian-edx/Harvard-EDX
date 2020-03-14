--[[
    GD50 2018
    Breakout Remake

    -- constants --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Some global constants for our application.
]]

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

-- number of ball skins
BALL_COUNT = 7

MAX_PADDLE_SIZE = 4
INITIAL_PADDLE_SIZE = 2

-- Number of powerup images available
POWERUPS_COUNT = 10
-- powerup spawn interval in seconds
MIN_POWERUP_INTERVAL = 3
MAX_POWERUP_INTERVAL = 6
-- powerup descent speed
MIN_POWERUP_SPEED = 20
MAX_POWERUP_SPEED = 100

KEY_SKIN = 10
