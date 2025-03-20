function love.load()

end

function love.update(dt)

end

function love.draw()
    local color = require("utils/convertColor")
    windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    xCenter, yCenter = windowWidth / 2, windowHeight / 2

    love.graphics.setColor(color.hex("#FF0000"))
    love.graphics.rectangle("fill", windowWidth / 2 - 100, windowWidth / 2 - 100, 1000, 200)
end

