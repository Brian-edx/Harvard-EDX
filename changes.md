
## General Changes

push.lua:101 Changed to love.window.getDPIScale().

main.lua:82 Added 'static' second parameter to all love.audio.newSource(...) calls.

main.lua:223 Crashes on love.filesystem.exists().  Change to love.filesystem.getInfo()

Brick.lua:81 Changed self.psystem:setAreaSpread('normal', 10, 10)
  to self.psystem:setEmissionArea('normal', 10, 10, 6.28, true)
  -- (because I got an error message recommending this)

## Add a Powerup feature
* Add class Powerup.lua.
* In main.lua:65 add gFrames['powerups'].
* In Util.lua add GenerateQuadsPowerups().
* Add require 'src/Powerup' to Dependencies.lua.
* Change self.ball to self.balls, an array.  Update all code to reflect this.
* Spawn powerups randomly, in PlayState.lua.
* If a powerup collides with the paddle, spawn 2 extra balls.
* Play continues until all balls have gone out of play.
* Allow up to 10 balls in play then pause powerup spawning.

## Grow and shrink the paddle as the score changes
* A higher score will give a larger paddle.
* Pass the score from PlayState.lua to Paddle:update()
* Use the score in Paddle.update() to adjust the paddle size.
* Change the paddle sprite to reflect the current size.

## Add a locked brick into the wall, unbreakable unless player has the "key powerup".
* The key powerup is the last one (index 10).
* Add a 'brick-hit-locked'wav' sound used when a locked brick is hit.
* After the player collects the key powerup, display a key icon beside the health hearts.
* Once the player has the key powerup a single hit destroys any locked brick.