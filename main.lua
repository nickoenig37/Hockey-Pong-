--Pong FINAL by Nicholas Koenig


-- push is a library allowing drawings to be put in the game at
-- a virtual resolution, opposed to however large the window size is;
-- used to provide a retro aesthetic

-- https://github.com/U1ydev/push
push = require 'push'


Class = require 'class'
--the "Class" library allows us to represent anything in
--the game as code, rather than keeping track of many disparate variables and methods
--https://github.com/vrld/hump/blob/master/class.lua

require 'Paddle'
--requiring my code from the Paddle class which stores position and dimensions for each Paddle

require 'Ball'
--requiring my code from the Ball class which stores position and dimensions for the ball


WINDOW_WIDTH= 1280
WINDOW_HEIGHT= 720

VIRTUAL_WIDTH= 432
VIRTUAL_HEIGHT= 243
--push command takes our original window sizes and turns it into a virtual resolution window
--provides a lower resolution which gives the 'classic' feel

PADDLE_SPEED = 200 --speed to move the paddle; mupltiplied by dt (arbitrary value)

local background = love.graphics.newImage('Ice_Hockey.jpg')


function love.load() --everything in this occurs as this function runs
    love.graphics.setDefaultFilter('nearest', 'nearest')
    -- use nearest-neighbor filtering to prevent blurred text and graphics

    love.window.setTitle('Nicholas Koenig Pong Hockey Assignment')
    --sets the title of our application window to the string of choice

    math.randomseed(os.time()) --different everytime we launch app (based on the current second)

    smallFont = love.graphics.newFont('PongFont.ttf', 8)
    --new font provides the retro look for any text
    largeFont = love.graphics.newFont('PongFont.ttf', 16)
    scoreFont = love.graphics.newFont('PongFont.ttf', 32)

    love.graphics.setFont(smallFont)
    --set Love2d's active font to the smallFont object that can be set to the active font as needed

    sounds = {  --initializing a sounds table here
        ['paddle_hit'] = love.audio.newSource ('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource ('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['Goal_Horn'] = love.audio.newSource('Goal-horn.mp3', 'static')

    }
    -- the strings in the square brackets are necessary to initialize key pairs in a table
    --after function it takes in the key path 'sounds/...etc' and we give it the key string 'static', which is the type of asset it is stored as.
    --allows us to reference it later using function "sounds.paddle_hit" or "sounds.['paddle_hit']"

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true, --part of resize update
        vsync = true
    })

    player1Score = 0 --Score variables used to render on screen and keep track of winner/actions
    player2Score = 0

    servingPlayer = 1
    --either going to be 1 or 2, based on who is scored on deciding who serves on following

    RALLY_COUNT = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    --paddle positions on the Y axis (only on y-axis because we only want them to move up/down)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 -2, 4, 4)
    -- velocity and position variables for our ball when starting game (in center)
    -- places ball in the middle of the screen



    gameState = 'start' --setting a string for start state
    --game state variable used to transition between different parts of the game
    --opposed to the play state, this is used for (beginning, menus, main game, score...)
    --determines behavior during render and update
end

--this function allows are game to be resizeable
--we just pass in the width and height to push so our virtual resolution can be resized as needed.
function love.resize(w, h)
    push:resize(w, h)
end



--[[love.update(dt) function runs every frame, with "dt" passed in, our delta in seconds since the last frame]]
function love.update(dt)
    if gameState == 'serve' then
        --initializes ball's velocity before switching to play state, initializes ball's velocity based on player who last scored
        ball.dy = math.random(-50,50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140,200)
        end
    elseif gameState == 'play' then -- must be in gamestate for this to occur

        -- refers to the collision statement with paddle in ball class
        -- if true, dx is reversed and slightly increased (speed)
        -- then the dy is altered based on the position of the collision
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.04 -- increasing speed by 4%
            ball.x = player1.x + 5 --moves it out of paddle collision box, or else an infinate collision will occur
            RALLY_COUNT = RALLY_COUNT + 1 --adds rallycount on collision

            --This function (below) keeps our velocity going in the same direction, but it's randomized
            if ball.dy < 0 then
                ball.dy = -math.random(10,150) -- if ball is aready negative, we want to keep it negative (random number between 10-150)
            else
                ball.dy = math.random(10,150) --makes ball go in the positive direction if it's already coming down
            end

            sounds['paddle_hit']:play()
        end



        --same operation as above but this time for player 2
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.04
            ball.x = player2.x - 4 --subtract 4 because that's the width of the ball
            RALLY_COUNT = RALLY_COUNT + 1 --adds rally count on collision
            --keeps the velocity going in the same direction, but randomized
            if ball.dy < 0 then
                ball.dy = -math.random(10,150) -- if ball is aready negative, we want to keep it negative
            else
                ball.dy = math.random(10,150) --makes ball go in the positive direction if it's already coming down
            end
            sounds['paddle_hit']:play()
        end


        -- this function below (if statements) detect the upper and lower screen boundary collision and changes the balls dt if they collide
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT -4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end



    --functions here are based on if ball goes to the left or right edge of the screen
    --if that happens, the ball goes back to start and updates the score
        if ball.x < 0 then --left edge of screen
            servingPlayer = 1
            player2Score = player2Score + 1
            RALLY_COUNT = 0 --Resets rally count
            sounds['Goal_Horn']:play()

            if player2Score == 10 then --if a score of 10 is reached, the game is over, show victory
                winningPlayer = 2
                gameState = 'done'

            else
                gameState = 'serve'
                --places ball back to center
                ball:reset()
            end
        end

        if ball.x  > VIRTUAL_WIDTH then --detects goal on Right side
            servingPlayer = 2
            player1Score = player1Score + 1
            RALLY_COUNT = 0   --resets RALLY count
            sounds['Goal_Horn']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'

            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end


    --These are the controls for when a two player game is selected
    if gameMode == 'TWO_PLAYERS' then
        --player 1 movement
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED

        elseif love.keyboard.isDown ('s') then
            player1.dy = PADDLE_SPEED

        else
            player1.dy = 0
        end

        --player 2 movement
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED

        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED

        else
            player2.dy = 0

        end
    end


    AI_REACTION = 0
    --based on the gamemode selected, the AI will react in 3 different ways
    --
    if gameMode == 'ONE_PLAYER_EASY' then
        AI_REACTION = VIRTUAL_WIDTH/4 --very low reaction
    elseif gameMode == 'ONE_PLAYER_HARD' then
        AI_REACTION = VIRTUAL_WIDTH/2  --not as low reaction
    elseif gameMode == 'RALLY' then
        AI_REACTION = VIRTUAL_WIDTH  --insane reaction
    end


    if gameMode == 'ONE_PLAYER_EASY' or gameMode == 'ONE_PLAYER_HARD' or gameMode == 'RALLY' then
        --Human (player 1) Controls
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED

        elseif love.keyboard.isDown ('s') then
            player1.dy = PADDLE_SPEED

        else
            player1.dy = 0
        end

        --AI CONTROLS/REACTION
        if ((ball.x - player2.x)^2)^(0.5)  < AI_REACTION then
            if (player2.y > (ball.y + ball.height/2))  then                    -- computer
                player2.dy = -PADDLE_SPEED --causes the AI Paddle to move downwards

            elseif (player2.y + player2.height < (ball.y + ball.height/2))  then
                player2.dy = PADDLE_SPEED --causes the AI Paddle to move upwards

            else
                player2.dy = 0
            end
        end
    end

    --This Causes the AI to Serve On its own
    if (gameMode == 'ONE_PLAYER_EASY' or gameMode == 'ONE_PLAYER_HARD' or gameMode == 'RALLY') and gameState == 'serve' and servingPlayer == 2 then
        ball.dx = -math.random(140, 200)
        ball.dy = math.random(-50, 50)
        gameState = 'play'
    end


    if gameState == 'play' then --if in playstate we want to update the dt
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end



function love.keypressed(key)
    --these allow us to select our gameMODE in the start menu
    if gameState == 'start' and key == '1' then
        gameMode = 'TWO_PLAYERS'
    end

    if gameState == 'start' and key == '2' then
        gameMode = 'ONE_PLAYER_EASY'
    end

    if gameState == 'start' and key == '3' then
        gameMode = 'ONE_PLAYER_HARD'
    end

    if gameState == 'start' and key == '4' then
        gameMode = 'RALLY'
    end

    if key == 'p' then
        gameState = 'start'
    end

    if key == 'escape' then
        love.event.quit() --allows function to close by clicking escape
    --tests game state/ commands based on that state
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'

        elseif gameState == 'serve' then
            gameState = 'play'

        elseif gameState == 'done' then
            gameState = 'serve' --game is simply in a restart phase here, but sets the serving player to the opponent

            ball:reset()

            --reset scores to 0
            player1Score = 0
            player2Score = 0

            --decide serving player as opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end




function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    --love.graphics.clear(40/255, 45/255, 52/255, 255/255) --function wipes the entire screen with a colour defined by an RGBA set, each from 0-255 (255 at end means it's not transparent)

    love.graphics.draw(background, 0, 0) --function draws our set background to screen

    love.graphics.setFont(smallFont)

    displayScore() --displays score in one command compared to recent 3 commands


    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(250, 0, 0, 255) --changes color to red
        love.graphics.printf('Welcome To Pong Hockey!', 0, 10, VIRTUAL_WIDTH, 'center') -- placing text with virtual width and height compared to past pong files
        love.graphics.printf('For Two Players, Press 1, Then Press Enter!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('For One Player EASY Mode, Press 2, Then Press Enter!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('For One Player HARD Mode, Press 3, Then Press Enter!', 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('For A RALLY Game, Press 4, Then Press Enter!', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('To Change GameModes At Any Point, Press P!', 0, 60, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(250,0,0, 255) --changes color a mix of RGB!
        love.graphics.printf('Player '.. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center') -- stringing in command for who is serving
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'play' then --no messages to display in play

    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.setColor(255,0,0, 255) --changes color to red
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' Wins, Congrats!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')

    end


    player1:render()
    player2:render()
    --render the paddles now using their class's render method

    ball:render()
    --render ball using its class's render

    displayFPS()
    -- new function just to demonstrate how to see FPS in Love2D

    push:apply('end') --ends rendering at virtual resolution
end

function displayFPS() --function is a simple FPS display across all states
    love.graphics.setFont(smallFont) --commented out because of font issues
    love.graphics.setColor(0, 255, 0, 255) --changes color of FPS display (this is green right now)
    love.graphics.print('FPS:' .. tostring(love.timer.getFPS()), 10, 10)  --the '..' is how you string concatenate in lua
end


function displayScore() --Simply draws the score to the screen
    --draws score on the left and right center on screen
    if gameMode == 'ONE_PLAYER_EASY' or gameMode == 'TWO_PLAYERS' or gameMode == 'ONE_PLAYER_HARD' then
        love.graphics.setFont(scoreFont)
        love.graphics.setColor(0,0,0, 255) --changes color to black
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    end

    if gameMode == 'RALLY' then
        love.graphics.setFont(scoreFont)
        love.graphics.setColor(0,0,0, 255) --changes color to black
        love.graphics.print(tostring(RALLY_COUNT), VIRTUAL_WIDTH / 2 - 8, VIRTUAL_HEIGHT / 2)
    end
end
