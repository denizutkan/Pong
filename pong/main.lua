WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

AI_SPEED = 70


Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()

    math.randomseed(os.time())


    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('PONG')
    
    -- sounds

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle.wav', 'static'),
        ['edge_hit'] = love.audio.newSource('edge.wav','static'),
        ['score'] = love.audio.newSource('score.wav','static')
    }


    -- fonts
    SmallFont = love.graphics.newFont('front.ttf', 8)
    ScoreFont = love.graphics.newFont('front.ttf', 32)
    VictoryFont = love.graphics.newFont('front.ttf', 24)

    -- Players Score
    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 2

    winner = 0


    --Paddles 
    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    --Ball
    ball = Ball((VIRTUAL_WIDTH / 2) - 2, (VIRTUAL_HEIGHT / 2) - 2, 4, 4)
    
    

    gameState = 'start'

    twoplayer = 'off'

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT, WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

function love.resize(w, h)
    push:resize(w , h)
end


function love.update(dt)
    
    paddle1:update(dt)
    paddle2:update(dt)

    if ball:collides(paddle1) then
        -- deflect to ball to the right
        ball.dx = - ball.dx * 1.1
        ball.x = paddle1.x + 5

        sounds['paddle_hit']:play()
    end

    if ball:collides(paddle2) then
        -- deflect to ball to the left
        ball.dx = - ball.dx * 1.1
        ball.x = paddle2.x - 5

        sounds['paddle_hit']:play()
    end

    if ball.y <= 0 then
        -- deflect the ball from the top edge
        ball.dy = - ball.dy 
        ball.y = 0

        sounds['edge_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
        -- deflect the ball from the bottom edge
        ball.dy = - ball.dy
        ball.y = VIRTUAL_HEIGHT - 4

        sounds['edge_hit']:play()
    end

    if ball.x <= 0 then
        
        ball:reset()
        servingPlayer = 1
        
        sounds['score']:play()
        
        ball.dx = 100
    
        player2Score = player2Score + 1


        if player2Score == 6 then
            gameState = 'victory'
            winner = 2

            twoplayer = 'off'
        
        else
            gameState = 'serve'  
            
            
        end

    end

    if ball.x >= VIRTUAL_WIDTH - 4 then

        ball:reset()
        servingPlayer = 2
        
        sounds['score']:play()

        ball.dx = - 100
        
        player1Score = player1Score + 1

        if player1Score == 6 then
            gameState = 'victory'
            winner = 1

            twoplayer = 'off'
        else
            gameState = 'serve'

            
        end

    end

     
    -- to move paddles

    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0     
    end

    if twoplayer == 'on' then

        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0     
        end

    else

        if ball.x > VIRTUAL_WIDTH / 2 then

            if ball.y - 5 > paddle2.y then

                paddle2.dy = AI_SPEED

            elseif ball.y -5 < paddle2.y then

                paddle2.dy = - AI_SPEED

            end
        else

            paddle2.dy = 0

        end

    end

    
    -- to move ball
    if gameState == 'play' then

        ball:update(dt)
        
    end
end

function love.keypressed(key)

    -- to quit
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        
        if gameState == 'start' or 'serve' then

            gameState = 'play'
        
        elseif gameState == 'victory' then

            gameState = 'start'
            
        
        end

    elseif key ==  't' and (gameState == 'start' or gameState == 'victory') then

        if twoplayer == 'off' then

            twoplayer = 'on'

        end


    end


end


function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255,45 / 255,52 / 255, 255 /255)
    
    -- Paddle position
    paddle1:render()
    paddle2:render()

    -- Ball position
    ball:render()

    displayFPS()


    
    love.graphics.setFont(SmallFont)
    
    love.graphics.print('Player 1', 15, 10)
    love.graphics.print('Player 2', VIRTUAL_WIDTH - 45, 10)
    -- Star and Play
    
    if gameState == 'start' then

        if twoplayer == 'off' then

            love.graphics.printf("To Play 2 player Press T", 0, 180,VIRTUAL_WIDTH,'center')
        end
        
        love.graphics.printf("Hello Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play", 0, 32, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then

        love.graphics.printf("Player ".. tostring(servingPlayer) .. "'s turn", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve", 0, 32, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'victory' then

        love.graphics.setFont(VictoryFont)
        love.graphics.printf("player ".. tostring(winner) .. " wins", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SmallFont)
        love.graphics.printf("Press Enter to restart", 0, 45, VIRTUAL_WIDTH, 'center')

        if twoplayer == 'off' then

            love.graphics.printf("To Play 2 player Press T", 0, 180,VIRTUAL_WIDTH,'center')
        end

        player2Score = 0
        player1Score = 0

        
        
    end
    --Players score position
    love.graphics.setFont(ScoreFont)
    love.graphics.print(player1Score,VIRTUAL_WIDTH / 2 - 50,VIRTUAL_HEIGHT / 4)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30,VIRTUAL_HEIGHT / 4)
    
    push:apply('end')
end

function displayFPS ()

    love.graphics.setColor(0, 1, 0, 1)

    love.graphics.setFont(SmallFont)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), 40, 20)

    love.graphics.setColor(1, 1, 1, 1)

end

