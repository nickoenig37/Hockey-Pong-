--Pong Remake by Nicholas Koenig

--Paddle Class

--Paddles will move up and down in order to stop the ball from going past and deflect towards opponent

Paddle = Class{}

function Paddle:init(x, y, width, height) --initializer function is called just to set up all variables in the class for use
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
    -- self is a reference to *this* object, whichever object is instantiated at the time this function is called.
end

function Paddle:update(dt)
    -- math.max ensures that it's at the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)

    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    -- math.min ensures that the paddle doesn't go any farther than the bottom of the screen minus the paddle's height
    end
end


function Paddle:render()
    love.graphics.setColor(255,0,0, 255) --changes color to red
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
--  To be called by our main function in `love.draw`, ideally. Uses
--  LÖVE2D's `rectangle` function, which takes in a draw mode as the first
--  argument as well as the position and dimensions for the rectangle. To
--  change the color, one must call `love.graphics.setColor`.
end

-- these commands are what we base our AI on!
-- This Causes the AI Paddle to Follow the BALL!

function Paddle:reset1()
    self.x = 10
    self.y = 30
    self.width = 5
    self.height = 20
    self.dy = 0
end

function Paddle:reset2()
    self.x = VIRTUAL_WIDTH - 10
    self.y = VIRTUAL_HEIGHT - 30
    self.width = 5
    self.height = 20
    self.dy = 0
end