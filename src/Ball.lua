--[[
    GD50
    Breakout Remake

    -- Ball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a ball which will bounce back and forth between the sides
    of the world space, the player's paddle, and the bricks laid out above
    the paddle. The ball can have a skin, which is chosen at random, just
    for visual variety.
]]

-- Ball = Class{}
Ball = Class{__includes = BaseBlock}

function Ball:init(skin)

    -- call BaseBlock setup
    self:setup()

    -- simple positional and dimensional variables
    self.width = 8
    self.height = 8

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = 0
    self.dx = 0

    -- this will effectively be the color of our ball, and we will index
    -- our table of Quads relating to the global block texture using this
    self.skin = skin
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Ball:collides_2(target)
    
    local dx = self.x - self.lastX
    local dy = self.y - self.lastY

    if dy ~= 0 then
        local angle = dx / dy

        -- did the ball pass downwards across the target top?
        local cameFromAbove = self.lastY < target.y and self.y >= target.y
        if cameFromAbove then
            local xIntersect = self.lastX + (target.y - self.lastY) * angle
            if xIntersect >= target.x and xIntersect < target.x + target.width then return true end
        else
            -- did the ball pass upwards across the target bottom?
            local targetBottom = target.y + target.height
            local cameFromBelow = self.lastY > targetBottom and self.y <= targetBottom
            if cameFromBelow then
                local xIntersect = self.lastX + (targetBottom - self.lastY) * angle
                if xIntersect >= target.x and xIntersect < target.x + target.width then return true end
            end
        end
    end

    if dx ~= 0 then
        local angle = dy / dx

        -- did the ball pass right across the target left edge?
        local cameFromLeft = self.lastX < target.x and self.x >= target.x
        if cameFromLeft then
            local yIntersect = self.lastY + (target.x - self.lastX) * angle
            if yIntersect >= target.y and yIntersect < target.y + target.height then return true end
        else
            -- did the ball pass left across the target right edge?
            local targetRight = target.y + target.height
            local cameFromRight = self.lastX > targetRight and self.x <= targetRight
            if cameFromRight then
                local yIntersect = self.lastY + (targetRight - self.lastX) * angle
                if yIntersect >= target.y and yIntersect < target.y + target.height then return true end
            end
        end
    end

    -- if the above aren't true, they're not overlapping
    return false
end

function Ball:collides_original(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Places the ball in the middle of the screen, with no movement.
]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.lastX = self.x
    self.lastY = self.y
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)

    self:move(dt)
    -- self.lastX = self.x
    -- self.lastY = self.y
    -- self.x = self.x + self.dx * dt
    -- self.y = self.y + self.dy * dt

    -- allow ball to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        gSounds['wall-hit']:play()
    end
end

function Ball:render()
    -- gTexture is our global texture for all blocks
    -- gBallFrames is a table of quads mapping to each individual ball skin in the texture
    love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin],
        self.x, self.y)
end