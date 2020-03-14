--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level

    self.recoverPoints = 5000

    self.lowestBrick = self:findLowestBrick()
    self.hasKey = false

    self.powerUps = {}
    self.powerupTimer = 0
    self.nextPowerupSpawnTime = math.random(MIN_POWERUP_INTERVAL, MAX_POWERUP_INTERVAL)
    self.slowestUpdate = 0

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

-- Don't bother checking all the brick for collisions if the ball is below this level.
-- A small optimisation, because I am finding collision detection is intermittently failing.
function PlayState:findLowestBrick()
    local lowest = 0
    for b, brick in pairs(self.bricks) do
        lowest = math.max(lowest, brick.y + brick.height)
    end
    lowest = lowest + 8
    print('Lowest brick = ' .. lowest)
    return lowest
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    local start = os.clock()

    -- update positions based on velocity
    self.paddle:update(dt)

    for b, ball in pairs(self.balls) do

        ball:update(dt)

        -- If the ball is near the bricks check for collisions.
        -- Otherwise check for collision with the paddle.
        if ball.y < self.lowestBrick then
            
            -- detect collision across all bricks with the ball
            for k, brick in pairs(self.bricks) do

                -- only check collision if we're in play
                if brick.inPlay and ball:collides(brick) then

                    -- add to score
                    self.score = self.score + brick:getScore() -- (brick.tier * 200 + brick.color * 25)

                    if brick.isLocked then
                        if self.hasKey then
                            brick:hit()
                        else
                            gSounds['brick-hit-locked']:play()
                        end
                    else
                        -- trigger the brick's hit function, which removes it from play
                        brick:hit()
                    end

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)
                        self.paddle.size = math.min(MAX_PADDLE_SIZE, self.paddle.size + 1)
                        -- multiply recover points by 2
                        self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            balls = self.balls,
                            recoverPoints = self.recoverPoints
                        })
                    end

                    --
                    -- collision code for bricks
                    --
                    -- we check to see if the opposite side of our velocity is outside of the brick;
                    -- if it is, we trigger a collision on that side. else we're within the X + width of
                    -- the brick and should check to see if the top or bottom edge is outside of the brick,
                    -- colliding on the top or bottom accordingly 
                    --

                    -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                    if ball.x + 2 < brick.x and ball.dx > 0 then
                        
                        -- flip x velocity and reset position outside of brick
                        ball.dx = -ball.dx
                        ball.x = brick.x - 8
                    
                    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                    elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                        
                        -- flip x velocity and reset position outside of brick
                        ball.dx = -ball.dx
                        ball.x = brick.x + 32
                    
                    -- top edge if no X collisions, always check
                    elseif ball.y < brick.y then
                        
                        -- flip y velocity and reset position outside of brick
                        ball.dy = -ball.dy
                        ball.y = brick.y - 8
                    
                    -- bottom edge if no X collisions or top collision, last possibility
                    else
                        
                        -- flip y velocity and reset position outside of brick
                        ball.dy = -ball.dy
                        ball.y = brick.y + 16
                    end

                    -- slightly scale the y velocity to speed up the game, capping at +- 150
                    if math.abs(ball.dy) < 150 then
                        ball.dy = ball.dy * 1.02
                    end

                    -- only allow colliding with one brick, for corners
                    break
                end
            end
        else
            if ball:collides(self.paddle) then
                -- raise ball above paddle in case it goes below it, then reverse dy
                ball.y = self.paddle.y - 8
                ball.dy = -ball.dy

                --
                -- tweak angle of bounce based on where it hits the paddle
                --

                -- if we hit the paddle on its left side while moving left...
                if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                    ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
                
                -- else if we hit the paddle on its right side while moving right...
                elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                    ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
                end

                gSounds['paddle-hit']:play()
            end

        end

        -- if ball goes below bounds remove it
        if ball.y >= VIRTUAL_HEIGHT then
            gSounds['hurt']:play()
            table.remove(self.balls, b) -- remove that ball
        end

    end -- for each ball

    -- if all balls go below bounds, revert to serve state and decrease health
    if #self.balls == 0 then
        self.health = self.health - 1
        self.paddle.size = math.max(1, self.paddle.size - 1)

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end

    -- Spawn powerups, unless we have a zillion balls already
    elseif #self.balls < 10 then
        -- don't spawn keys if we already have one
        self:spawnPowerups(dt)
    end

    -- local gotPowerup = false
    for p, powerup in pairs(self.powerUps) do
        powerup:update(dt)
        if powerup:collides(self.paddle) then
            -- gotPowerup = true
            if powerup.isKey then
                print('Got the key!')
                self.hasKey = true
            else
                -- Spawn 2 extra balls
                self:spawnExtraBalls()
            end
            gSounds['paddle-hit']:play()
            table.remove(self.powerUps, p)  -- remove that entry
        elseif powerup.y > VIRTUAL_WIDTH then
            -- self.powerUps[p] = nil  -- remove that entry
            table.remove(self.powerUps, p)  -- remove that entry
        end
    end
    -- Uncomment this if we only want one powerup active at once.
    -- if gotPowerup then self.powerUps = {} end   -- reset

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    local finish = os.clock()   -- returns down to milliseconds
    local elapsed = finish - start
    -- print(string.format("%.3f", finish))
    if elapsed > self.slowestUpdate then self.slowestUpdate = elapsed end
end

function PlayState:spawnPowerups(dt)
    self.powerupTimer = self.powerupTimer + dt
    if self.powerupTimer >= self.nextPowerupSpawnTime then
        self.nextPowerupSpawnTime = math.random(MIN_POWERUP_INTERVAL, MAX_POWERUP_INTERVAL)
        self.powerupTimer = 0
        local powerup = Powerup()
        powerup.x = math.random(20, VIRTUAL_WIDTH - 20)
        powerup.y = 0
        powerup.dy = math.random(MIN_POWERUP_SPEED, MAX_POWERUP_SPEED)

        -- this will effectively be the color of our powerup, and we will index
        -- our table of Quads relating to the global block texture using this
        if self.hasKey then
            -- don't spawn more keys once we have one
            powerup.skin = math.random(POWERUPS_COUNT - 1)
        else
            powerup.skin = math.random(POWERUPS_COUNT)
        end
        powerup.isKey = powerup.skin == KEY_SKIN

        table.insert(self.powerUps, powerup)
    end
end

function PlayState:spawnExtraBalls()
    for i = 1, 2 do
        local ball = Ball()
        ball.skin = math.random(BALL_COUNT)
        ball.x = self.paddle.x + (self.paddle.width / 2)
        ball.y = self.paddle.y - ball.height
        -- give ball random starting velocity
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
        table.insert(self.balls, ball)
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for i, ball in pairs(self.balls) do
        ball:render()
    end

    for p, powerup in pairs(self.powerUps) do
        powerup:render(dt)
    end

    renderScore(self.score)
    renderHealth(self.health)

    if self.hasKey then
        love.graphics.draw(gTextures['key'], VIRTUAL_WIDTH - 130, 4)
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    -- Extra debug code
    -- love.graphics.setFont(gFonts['small'])
    -- love.graphics.printf(#self.balls .. " balls", 0, VIRTUAL_HEIGHT - 16, VIRTUAL_WIDTH - 10, 'right')
    -- love.graphics.printf(string.format("%.3f sec", self.slowestUpdate), 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH - 10, 'right')

end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end