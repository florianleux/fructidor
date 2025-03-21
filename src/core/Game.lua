-- src/core/Game.lua

-- Constants
local DEFAULT_WINDOW_WIDTH = 1920
local DEFAULT_WINDOW_HEIGHT = 1080
local BACKGROUND_COLOR = "#f8f8f8"

-- Main game controller
local Game = {}
Game.__index = Game

-- Import components
local GameState = require("src/core/GameState")
local GameLevel = require("src/elements/level/GameLevel")
local color = require("utils/convertColor")

-- Constructor
function Game:new()
    local self = setmetatable({}, Game)
    
    -- Game state
    self.gameState = GameState:new()
    
    -- Game level
    self.currentLevel = nil
    
    -- Screen dimensions
    self.width = DEFAULT_WINDOW_WIDTH
    self.height = DEFAULT_WINDOW_HEIGHT
    
    return self
end

-- Initialize game components
function Game:initialize()
    -- Create game level
    self.currentLevel = GameLevel:new()
    self.currentLevel:initialize("normal")
    
    -- Place components on screen
    self:placeComponents()
    
    -- Initialize game state
    self.gameState:changeState("gameplay")
end

-- Position components on screen
function Game:placeComponents()
    -- Get screen dimensions
    self.width, self.height = love.graphics.getDimensions()
    
    -- Position level components
    self.currentLevel:setPosition(self.width, self.height)
end

-- Update game state and components
function Game:update(dt)
    -- Update based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Update level
        self.currentLevel:update(dt)
    end
    
    -- Handle window resize
    local w, h = love.graphics.getDimensions()
    if w ~= self.width or h ~= self.height then
        self.width, self.height = w, h
        self:placeComponents()
    end
end

-- Draw the game
function Game:draw()
    -- Clear screen with background color
    love.graphics.setColor(color.hex(BACKGROUND_COLOR))
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Draw based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Draw level
        self.currentLevel:draw()
    end
end

-- Handle key presses
function Game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "n" and self.gameState:getCurrentState() == "gameplay" then
        -- Debug: advance to next round
        self.currentLevel:nextRound()
    end
end

-- Handle mouse presses
function Game:mousepressed(x, y, button)
    -- Handle mouse press based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Forward to level
        self.currentLevel:mousepressed(x, y, button)
    end
end

-- Handle mouse movement
function Game:mousemoved(x, y, dx, dy)
    -- Handle mouse movement based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Forward to level
        self.currentLevel:mousemoved(x, y, dx, dy)
    end
end

-- Handle mouse releases
function Game:mousereleased(x, y, button)
    -- Handle mouse release based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Forward to level
        self.currentLevel:mousereleased(x, y, button)
    end
end

return Game