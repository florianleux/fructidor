-- src/elements/dice/Die.lua

-- Constants
local DIE_SIZE = 60                    -- Width and height of the die
local DIE_BACKGROUND_COLOR = "#ffffff" -- Die background color
local DIE_BORDER_COLOR = "#666666"     -- Die border color
local DIE_BORDER_WIDTH = 2             -- Border width
local DIE_CORNER_RADIUS = 6            -- Rounded corner radius
local DIE_TEXT_COLOR = "#333333"       -- Text color for die value
local DIE_TEXT_SIZE = 30               -- Font size for die value
local DIE_LABEL_SIZE = 15              -- Font size for die label
local DIE_MIN_VALUE = 1                -- Minimum value
local DIE_MAX_VALUE = 6                -- Maximum value

-- Die is a base class for dice
local Die = {}
Die.__index = Die

-- Import color utility
local color = require("utils/convertColor")

-- Constructor
function Die:new(name, minValue, maxValue)
    local self = setmetatable({}, Die)

    -- Basic properties
    self.name = name or "Die" -- Die name
    self.minValue = minValue or DIE_MIN_VALUE
    self.maxValue = maxValue or DIE_MAX_VALUE

    -- Position and size
    self.x = 0
    self.y = 0
    self.size = DIE_SIZE

    -- Current value
    self.value = nil

    -- Display options
    self.backgroundColor = DIE_BACKGROUND_COLOR
    self.textColor = DIE_TEXT_COLOR

    return self
end

-- Set die position
function Die:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Roll the die
function Die:roll()
    self.value = math.random(self.minValue, self.maxValue)
    return self.value
end

-- Set die value directly
function Die:setValue(value)
    if value >= self.minValue and value <= self.maxValue then
        self.value = value
    end
end

-- Get die value
function Die:getValue()
    return self.value
end

-- Update die state
function Die:update(dt)
    -- Currently no dynamic behavior needed
end

-- Draw the die
function Die:draw()
    -- Draw die background
    love.graphics.setColor(color.hex(self.backgroundColor))
    love.graphics.rectangle(
        "fill",
        self.x - self.size / 2,
        self.y - self.size / 2,
        self.size,
        self.size,
        DIE_CORNER_RADIUS
    )

    -- Draw die border
    love.graphics.setColor(color.hex(DIE_BORDER_COLOR))
    love.graphics.setLineWidth(DIE_BORDER_WIDTH)
    love.graphics.rectangle(
        "line",
        self.x - self.size / 2,
        self.y - self.size / 2,
        self.size,
        self.size,
        DIE_CORNER_RADIUS
    )

    -- Draw die value
    love.graphics.setColor(color.hex(self.textColor))
    local valueText = self.value or "?"
    love.graphics.printf(
        tostring(valueText),
        self.x - self.size / 2,
        self.y - DIE_TEXT_SIZE / 2,
        self.size,
        "center"
    )

    -- Draw die name
    love.graphics.printf(
        self.name,
        self.x - self.size / 2,
        self.y + self.size / 4,
        self.size,
        "center"
    )

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Handle mouse press
function Die:mousepressed(x, y, button)
    -- Check if press is on die
    if self:containsPoint(x, y) then
        -- Roll the die
        self:roll()
        return true
    end
    return false
end

-- Check if point is on die
function Die:containsPoint(x, y)
    return x >= self.x - self.size / 2 and x <= self.x + self.size / 2 and
        y >= self.y - self.size / 2 and y <= self.y + self.size / 2
end

return Die
