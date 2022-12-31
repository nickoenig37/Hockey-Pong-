-- PONG Remake Game by Nicholas Koenig

-- Ball Class

-- The class represents the ball which will bounce back and forth between paddles and walls until it passes a left
-- or right boundary of the screen, scoring a point for the opponent.

Ball = Class{}

function Ball:init(x, y, width, height) --defining a constructor or an init (initializer) function
    self.x = x
    self.y = y
    self.width = width
    self.height = height
-- the funtion allows us to initialize our ball with whatever we want (an x,y,width, and height)
--"self" is a common word in object oriented program that mean whatever object we're creating with this class is going to be self

    self.dy = math.random(2) == 1 and -100 or 100 --function returns a random value between left and right number
    self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
    --setting the random values from before
    --The variables keep track of our velocity on both the x/y axis since the ball moves in 2 dimensions
    --Places the ball in the middle of the screen, with an initial random velocity on both axes.
end

--The ball:collides(paddle) function expects a paddle as an argument to return either true or false,
--which is based on whether their rectabgles overlap at a point in dt

function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    -- this checks to see if the left edge of either the ball or paddle is further to the right than the right edge of the other

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end
    -- this checks to see if the bottom edge of either is higher than the top edge of the other

    return true
    -- this means if both of the above are false then they must be overlapping
end


function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
end
-- This simply applies velocity to position, scaled by deltaTime.

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.setColor(0, 0, 0, 255) --changes color of ball 'puck' to black
    love.graphics.circle('fill', self.x, self.y, self.width, self.height)
end


