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
local Garden = require("src/elements/board/Garden")
local CardHand = require("src/elements/cards/CardHand")
local Deck = require("src/elements/cards/Deck")
local RoundBoard = require("src/elements/board/RoundBoard")
local ScoreBoard = require("src/elements/board/ScoreBoard")
local SunDie = require("src/elements/dice/SunDie")
local RainDie = require("src/elements/dice/RainDie")
local color = require("utils/convertColor")

-- Constructor
function Game:new()
    local self = setmetatable({}, Game)
    
    -- Game state
    self.gameState = GameState:new()
    
    -- Game components
    self.garden = nil
    self.cardHand = nil
    self.deck = nil
    self.roundBoard = nil
    self.scoreBoard = nil
    self.sunDie = nil
    self.rainDie = nil
    
    -- Screen dimensions
    self.width = DEFAULT_WINDOW_WIDTH
    self.height = DEFAULT_WINDOW_HEIGHT
    
    return self
end

-- Initialize game components
function Game:initialize()
    -- Create game components
    self.garden = Garden:new(3, 2) -- 3x2 grid
    self.cardHand = CardHand:new(5) -- 5 cards max
    self.deck = Deck:new()
    self.roundBoard = RoundBoard:new()
    self.scoreBoard = ScoreBoard:new()
    self.sunDie = SunDie:new()
    self.rainDie = RainDie:new()
    
    -- Place components on screen
    self:placeComponents()
    
    -- Initialize game state
    self.gameState:changeState("gameplay")
    
    -- Deal initial cards
    self.cardHand:drawCards(self.deck, 5)
end

-- Position components on screen
function Game:placeComponents()
    -- Get screen dimensions
    self.width, self.height = love.graphics.getDimensions()
    
    -- Center the garden
    self.garden:setPosition(self.width / 2, self.height / 2)
    
    -- Place score in top left
    self.scoreBoard:setPosition(20, 20)
    
    -- Place round board in top center
    self.roundBoard:setPosition(self.width / 2, 50)
    
    -- Place dice below round board
    self.sunDie:setPosition(self.width / 2 - 30, 120)
    self.rainDie:setPosition(self.width / 2 + 30, 120)
    
    -- Place card hand at bottom
    self.cardHand:setPosition(self.width / 2, self.height - 100)
end

-- Update game state and components
function Game:update(dt)
    -- Update based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Update all components
        self.garden:update(dt)
        self.cardHand:update(dt)
        self.roundBoard:update(dt)
        self.sunDie:update(dt)
        self.rainDie:update(dt)
        self.scoreBoard:update(dt)
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
        -- Draw all components
        self.garden:draw()
        self.cardHand:draw()
        self.roundBoard:draw()
        self.sunDie:draw()
        self.rainDie:draw()
        self.scoreBoard:draw()
    end
end

-- Handle key presses
function Game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

-- Handle mouse presses
function Game:mousepressed(x, y, button)
    -- Handle mouse press based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Check if clicked on garden
        self.garden:mousepressed(x, y, button)
        
        -- Check if clicked on card
        self.cardHand:mousepressed(x, y, button)
        
        -- Check if clicked on dice
        self.sunDie:mousepressed(x, y, button)
        self.rainDie:mousepressed(x, y, button)
        
        -- Check if clicked on round board
        self.roundBoard:mousepressed(x, y, button)
    end
end

-- Handle mouse releases
function Game:mousereleased(x, y, button)
    -- Handle mouse release based on current state
    local currentState = self.gameState:getCurrentState()
    
    if currentState == "gameplay" then
        -- Check if released on garden
        self.garden:mousereleased(x, y, button)
        
        -- Check if released on card
        self.cardHand:mousereleased(x, y, button)
    end
end

return Game