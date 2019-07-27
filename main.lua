function love.load()
    love.mouse.setVisible(false)

    player = {
        img = love.graphics.newImage("sheep.png"),
        x = 0,
        y = 0,
        width = 50,
        height = 50
    }

    currentLevel = 1
    levels = {
        {
            {x = 100, y = 100}, {x = 300, y = 300}
        },
        {
            {x = 100, y = 100}, {x = 200, y = 200}, {x = 100, y = 350}, {x = 300, y = 300},
            {x = 200, y = 100}, {x = 300, y = 200}, {x = 200, y = 350}, {x = 300, y = 300},
            {x = 200, y = 275}, {x = 320, y = 350}
        },
        {
            {x = 200, y = 200},{x = 250, y = 200},{x = 300, y = 200},{x = 350, y = 200},
            {x = 200, y = 350}, {x = 200, y = 305}
        },
    }
    goals = {
        {x = 350, y = 350}, {x = 250, y = 350}, {x = 350, y = 250}
    }
    spikeImg = love.graphics.newImage("spike.png")
    grassImg = love.graphics.newImage("grass.png")

    isStartScreen = true
    startScreenImg = love.graphics.newImage("startScreen.png")
    startText = love.graphics.newImage("flashing.png")
    isOn = 1
    flashTimer = 0.5

    loop = love.audio.newSource("loop.mp3", "stream")
    loop:setLooping(true)
    loop:play()

    mustMoveCursor = false
    pleaseImg = love.graphics.newImage("please.png")

    hasWon = false
    wonImg = love.graphics.newImage("won.png")
end

function love.draw()
    if hasWon then
        love.graphics.draw(wonImg)
    else
        if isStartScreen then
            love.graphics.draw(startScreenImg)
            if isOn == 1 then
                love.graphics.draw(startText, 0, 300)
            end
        else
            love.graphics.draw(player.img, player.x, player.y)
            for _, spike in ipairs(levels[currentLevel]) do
                love.graphics.draw(spikeImg, spike.x, spike.y)
            end
            love.graphics.draw(grassImg, goals[currentLevel].x, goals[currentLevel].y)
            if mustMoveCursor then
                love.graphics.draw(pleaseImg)
            end
        end
    end
end

function love.update(dt)
    if not hasWon then
        if isStartScreen then
            flashTimer = flashTimer - dt
            if flashTimer < 0 then
                flashTimer = 0.5
                isOn = isOn * -1
            end
        else
            if not mustMoveCursor then
                player.x = love.mouse.getX()
                player.y = love.mouse.getY()

                for _, spike in ipairs(levels[currentLevel]) do
                    if isColliding(player, spike) then
                        player.x = 0
                        player.y = 0
                        mustMoveCursor = true
                        love.mouse.setVisible(true)
                        ouchSound = love.audio.newSource("ouch.mp3", "static")
                        ouchSound:play()
                    end
                end
                if isColliding(player, goals[currentLevel]) then
                    if currentLevel == #levels then
                        hasWon = true
                        loop:stop()
                        love.audio.newSource("winner.mp3", "stream"):play()
                    else
                        love.audio.newSource("beat.mp3", "static"):play()
                    end
                    currentLevel = currentLevel + 1
                    mustMoveCursor = true
                    love.mouse.setVisible(true)
                end 
            else
                if love.mouse.getX() <= 50 and love.mouse.getY() <= 50 then
                    mustMoveCursor = false
                    love.mouse.setVisible(false)
                end
            end
        end
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if isStartScreen then
        if key == "space" then
            startGame()
        end
    end
end

function startGame()
    isStartScreen = false
end

-- all images are 50
function isColliding(obj1, obj2)
    return obj1.x + 50 > obj2.x and obj1.x < obj2.x + 50 and
    obj1.y + 50 > obj2.y and obj1.y < obj2.y + 50 
end