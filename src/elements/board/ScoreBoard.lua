-- src/elements/board/ScoreBoard.lua

-- Constants
local BOARD_WIDTH = 200                -- Board width
local BOARD_HEIGHT = 80                -- Board height
local BOARD_BACKGROUND_COLOR = "#e0e8f0"  -- Background color
local BOARD_BORDER_COLOR = "#888888"   -- Border color
local BOARD_BORDER_WIDTH = 2           -- Border width
local BOARD_CORNER_RADIUS = 5          -- Corner radius
local PROGRESS_BAR_HEIGHT = 15         -- Height of progress bar
local PROGRESS_BAR_BACKGROUND = "#d0d0d0"  -- Progress bar background
local PROGRESS_BAR_FILL = "#80b080"    -- Progress bar fill color
local TEXT_COLOR = "#333333"           -- Text color
local TEXT_SIZE = 14                   -- Font size

-- ScoreBoard displays score and objectives
local ScoreBoard = {}
ScoreBoard.__index = ScoreBoard

-- Import color utility
local color = require("utils/convertColor")

-- Constructor
function ScoreBoard:new()
    local self = setmetatable({}, ScoreBoard)
    
    -- Position and size
    self.x = 0
    self.y = 0
    self.width = BOARD_WIDTH
    self.height = BOARD_HEIGHT
    
    -- Score tracking
    self.currentScore = 0
    self.targetScore = 100
    self.florins = 25
    
    return self
end

-- Set score board position
function ScoreBoard:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Add points to score
function ScoreBoard:addScore(points)
    self.currentScore = self.currentScore + points
end

-- Add florins (currency)
function ScoreBoard:addFlorins(amount)
    self.florins = self.florins + amount
end

-- Spend florins
function ScoreBoard:spendFlorins(amount)
    if amount <= self.florins then
        self.florins = self.florins - amount
        return true
    end
    return false  -- Not enough florins
end

-- Set target score
function ScoreBoard:setTarget(target)
    self.targetScore = target
end

-- Check if target score is reached
function ScoreBoard:isTargetReached()
    return self.currentScore >= self.targetScore
end

-- Get progress percentage
function ScoreBoard:getProgress()
    local progress = self.currentScore / self.targetScore
    return math.min(progress, 1.0)  -- Cap at 100%
end

-- Update score board
function ScoreBoard:update(dt)
    -- Currently no dynamic behavior needed
end

-- Draw score board
function ScoreBoard:draw()
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
    
    -- Draw score text
    love.graphics.setColor(color.hex(TEXT_COLOR))
    love.graphics.print(
        "Score: " .. self.currentScore .. "/" .. self.targetScore,
        self.x + 10,
        self.y + 10
    )
    
    -- Draw progress bar background
    love.graphics.setColor(color.hex(PROGRESS_BAR_BACKGROUND))
    love.graphics.rectangle(
        "fill",
        self.x + 10,
        self.y + 35,
        self.width - 20,
        PROGRESS_BAR_HEIGHT
    )
    
    -- Draw progress bar fill
    local progressWidth = (self.width - 20) * self:getProgress()
    love.graphics.setColor(color.hex(PROGRESS_BAR_FILL))
    love.graphics.rectangle(
        "fill",
        self.x + 10,
        self.y + 35,
        progressWidth,
        PROGRESS_BAR_HEIGHT
    )
    
    -- Draw florins
    love.graphics.setColor(color.hex(TEXT_COLOR))
    love.graphics.print(
        "Florins: " .. self.florins,
        self.x + 10,
        self.y + 55
    )
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return ScoreBoard