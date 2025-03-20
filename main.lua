function love.load()

end

function love.update(dt)

end

function love.draw()
    local color = require("utils/convertColor")
    windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()'
    '
    xCenter, yCenter = windowWidth / 2, windowHeight / 2

    love.graphics.setColor(color.hex("#FF0000"))
    love.graphics.rectangle("fill", t.window.width / 2 - 100, t.window.height / 2 - 100, 1000, 200)
end

