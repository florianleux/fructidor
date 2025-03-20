-- main.lua
-- Main entry point for the Fructidor game

-- Import the Game controller
local Game = require("src/core/Game")

-- Global game instance
local game

-- Called once at startup
function love.load()
    -- Initialize random seed
    math.randomseed(os.time())
    
    -- Create game instance
    game = Game:new()
    
    -- Initialize game components
    game:initialize()
    
    -- Set window title
    love.window.setTitle("Fructidor")
    
    -- Enable key repeat for text input
    love.keyboard.setKeyRepeat(true)
 end

-- Update game state
function love.update(dt)
    -- Update game components
    game:update(dt)
end

-- Draw game elements
function love.draw()
    -- Draw game components
    game:draw()
end

-- Handle key press events
function love.keypressed(key, scancode, isrepeat)
    game:keypressed(key)
end

-- Handle mouse press events
function love.mousepressed(x, y, button, istouch, presses)
    game:mousepressed(x, y, button)
end

-- Handle mouse release events
function love.mousereleased(x, y, button, istouch, presses)
    game:mousereleased(x, y, button)
end