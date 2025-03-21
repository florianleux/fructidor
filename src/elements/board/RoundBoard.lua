-- src/elements/board/RoundBoard.lua

-- Constants
local TOTAL_ROUNDS = 8                 -- Total number of rounds in a game
local ROUNDS_PER_SEASON = 2           -- Rounds per season
local BOARD_WIDTH = 400               -- Board width
local BOARD_HEIGHT = 60               -- Board height
local BOARD_BACKGROUND_COLOR = "#d0e0f0"  -- Background color
local BOARD_BORDER_COLOR = "#666666"  -- Border color
local BOARD_BORDER_WIDTH = 2           -- Border width
local BOARD_CORNER_RADIUS = 5          -- Corner radius
local ROUND_INDICATOR_RADIUS = 10      -- Radius of round indicators
local ROUND_INDICATOR_SPACING = 40     -- Spacing between round indicators
local ROUND_COLOR_CURRENT = "#333333"  -- Color for current round
local ROUND_COLOR_COMPLETED = "#888888"  -- Color for completed rounds
local ROUND_COLOR_UPCOMING = "#ffffff"  -- Color for upcoming rounds
local SEASON_COLORS = {                -- Colors for the four seasons
    "#a8e6cf",  -- Spring
    "#ffd3b6",  -- Summer
    "#ff8b94",  -- Autumn
    "#d3e0ea"   -- Winter
}
local SEASON_NAMES = {"Spring", "Summer", "Autumn", "Winter"}

-- Import dependencies
local Round = require("src/elements/board/Round")
local color = require("utils/convertColor")

-- RoundBoard manages the rounds and seasons
local RoundBoard = {}
RoundBoard.__index = RoundBoard

-- Constructor
function RoundBoard:new()
    local self = setmetatable({}, RoundBoard)
    
    -- Position
    self.x = 0
    self.y = 0
    self.width = BOARD_WIDTH
    self.height = BOARD_HEIGHT
    
    -- Rounds
    self.rounds = {}
    self.currentRound = 1
    
    -- Create rounds
    self:createRounds()
    
    return self
end

-- Create the rounds
function RoundBoard:createRounds()
    for i = 1, TOTAL_ROUNDS do
        -- Calculate season index (0-3)
        local seasonIndex = math.floor((i - 1) / ROUNDS_PER_SEASON) + 1
        
        -- Create round
        local round = Round:new(i, SEASON_NAMES[seasonIndex])
        table.insert(self.rounds, round)
    end
end

-- Set board position
function RoundBoard:setPosition(x, y)
    self.x = x - self.width / 2  -- Center horizontally
    self.y = y
end

-- Advance to next round
function RoundBoard:nextRound()
    if self.currentRound < TOTAL_ROUNDS then
        self.currentRound = self.currentRound + 1
        return self.rounds[self.currentRound]
    end
    return nil  -- No more rounds
end

-- Get current round
function RoundBoard:getCurrentRound()
    return self.rounds[self.currentRound]
end

-- Get current season
function RoundBoard:getCurrentSeason()
    local roundObj = self:getCurrentRound()
    return roundObj.season
end

-- Update round board
function RoundBoard:update(dt)
    -- Currently no dynamic behavior needed
end

-- Draw round board
function RoundBoard:draw()
    -- Draw board background
    love.graphics.setColor(color.hex(BOARD_BACKGROUND_COLOR))
    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.width,
        self.height,
        BOARD_CORNER_RADIUS
    )
    
    -- Draw board border
    love.graphics.setColor(color.hex(BOARD_BORDER_COLOR))
    love.graphics.setLineWidth(BOARD_BORDER_WIDTH)
    love.graphics.rectangle(
        "line",
        self.x,
        self.y,
        self.width,
        self.height,
        BOARD_CORNER_RADIUS
    )
    
    -- Draw line connecting round indicators
    love.graphics.line(
        self.x + ROUND_INDICATOR_SPACING,
        self.y + self.height / 2,
        self.x + self.width - ROUND_INDICATOR_SPACING,
        self.y + self.height / 2
    )
    
    -- Draw round indicators
    for i = 1, TOTAL_ROUNDS do
        -- Calculate indicator position
        local indicatorX = self.x + (i * ROUND_INDICATOR_SPACING)
        local indicatorY = self.y + self.height / 2
        
        -- Determine season color
        local seasonIndex = math.floor((i - 1) / ROUNDS_PER_SEASON) + 1
        love.graphics.setColor(color.hex(SEASON_COLORS[seasonIndex]))
        
        -- Draw round background based on state
        if i < self.currentRound then
            -- Completed round
            love.graphics.setColor(color.hex(ROUND_COLOR_COMPLETED))
        elseif i == self.currentRound then
            -- Current round
            love.graphics.setColor(color.hex(ROUND_COLOR_CURRENT))
        else
            -- Upcoming round
            love.graphics.setColor(color.hex(ROUND_COLOR_UPCOMING))
        end
        
        -- Draw round indicator
        love.graphics.circle("fill", indicatorX, indicatorY, ROUND_INDICATOR_RADIUS)
        
        -- Draw round indicator border
        love.graphics.setColor(color.hex(BOARD_BORDER_COLOR))
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", indicatorX, indicatorY, ROUND_INDICATOR_RADIUS)
        
        -- Draw round number
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(
            tostring(i),
            indicatorX - ROUND_INDICATOR_RADIUS,
            indicatorY - 6,
            ROUND_INDICATOR_RADIUS * 2,
            "center"
        )
    end
    
    -- Draw current season information
    love.graphics.setColor(0, 0, 0)
    local roundObj = self:getCurrentRound()
    local roundText = "Round " .. self.currentRound .. "/" .. TOTAL_ROUNDS
    local seasonText = roundObj.season
    
    -- Draw text
    love.graphics.printf(
        roundText,
        self.x,
        self.y - 40,
        self.width,
        "center"
    )
    
    love.graphics.printf(
        seasonText,
        self.x,
        self.y - 20,
        self.width,
        "center"
    )
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Handle mouse press
function RoundBoard:mousepressed(x, y, button)
    -- Currently no interactive behavior
end

-- Handle mouse release
function RoundBoard:mousereleased(x, y, button)
    -- Currently no interactive behavior for mouse release
    -- Added to ensure interface compatibility
    return false
end

return RoundBoard