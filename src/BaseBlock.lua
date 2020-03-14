
BaseBlock = Class{}

function BaseBlock:setup()
  self.x = 0
  self.y = 0
  self.lastX = 0
  self.lastY = 0
  self.dx = 0
  self.dy = 0
end

function BaseBlock:move(dt)
  self.lastX = self.x
  self.lastY = self.y
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

function BaseBlock:collides(target)
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

