-- src/elements/cards/Card.lua

-- Constants
local CARD_WIDTH = 80                   -- Width of a card
local CARD_HEIGHT = 120                 -- Height of a card
local CARD_BACKGROUND_COLOR = "#ffffff" -- Card background color
local CARD_BORDER_COLOR = "#666666"     -- Card border color
local CARD_BORDER_WIDTH = 2             -- Width of card border
local CARD_CORNER_RADIUS = 5            -- Rounded corner radius
local CARD_TEXT_COLOR = "#333333"       -- Card text color
local CARD_TEXT_SIZE = 12               -- Font size for card text
local CARD_TITLE_SIZE = 14              -- Font size for card title
local CARD_HOVER_SCALE = 2              -- Scale factor when card is hovered

-- Card represents a playable card (plant or item)
local Card = {}
Card.__index = Card

-- Constructor
function Card:new(type, family, name)
    local self = setmetatable({}, Card)

    -- Card properties
    self.type = type or "plant"        -- Type of card (plant)
    self.family = family or "brassika" -- Plant family (brassika, solana)
    self.name = name or "Unknown"      -- Name of the card

    -- Position and size
    self.x = 0
    self.y = 0
    self.width = CARD_WIDTH
    self.height = CARD_HEIGHT
    self.rotation = 0 -- Rotation in radians

    -- State
    self.isHovered = false
    self.isSelected = false
    self.isVisible = true

    -- Get color conversion utility
    self.color = require("utils/convertColor")

    return self
end

-- Set card position
function Card:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Set card rotation
function Card:setRotation(rotation)
    self.rotation = rotation
end

-- Update card state
function Card:update(dt)
    -- Update hover state
    local mouseX, mouseY = love.mouse.getPosition()
    self.isHovered = self:containsPoint(mouseX, mouseY)
end

-- Draw the card
function Card:draw()
    -- Only draw if visible
    if not self.isVisible then
        return
    end

    -- Save the current transformation
    love.graphics.push()

    -- Move to card position
    love.graphics.translate(self.x, self.y)

    -- Apply rotation
    love.graphics.rotate(self.rotation)

    -- Apply scaling if hovered
    local scale = 1
    if self.isHovered then
        scale = CARD_HOVER_SCALE
        self.rotation = 0
        love.graphics.translate(0, -100)
    end
    love.graphics.scale(scale, scale)

    -- Draw card background
    love.graphics.setColor(self.color.hex(CARD_BACKGROUND_COLOR))
    love.graphics.rectangle(
        "fill",
        -self.width / 2,
        -self.height / 2,
        self.width,
        self.height,
        CARD_CORNER_RADIUS
    )

    -- Draw card border
    love.graphics.setColor(self.color.hex(CARD_BORDER_COLOR))
    love.graphics.setLineWidth(CARD_BORDER_WIDTH)
    love.graphics.rectangle(
        "line",
        -self.width / 2,
        -self.height / 2,
        self.width,
        self.height,
        CARD_CORNER_RADIUS
    )

    -- Draw card title
    love.graphics.setColor(self.color.hex(CARD_TEXT_COLOR))
    love.graphics.printf(
        self.name,
        -self.width / 2 + 5,
        -self.height / 2 + 10,
        self.width - 10,
        "center"
    )

    -- Draw card type
    love.graphics.printf(
        self.type:upper(),
        -self.width / 2 + 5,
        -self.height / 2 + 30,
        self.width - 10,
        "center"
    )

    -- Draw card family
    love.graphics.printf(
        self.family:upper(),
        -self.width / 2 + 5,
        0,
        self.width - 10,
        "center"
    )

    -- Restore the transformation
    love.graphics.pop()

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Check if point is inside card
function Card:containsPoint(x, y)
    -- Transform point to local coordinates
    local dx = x - self.x
    local dy = y - self.y

    -- Rotate point
    local cos_r = math.cos(-self.rotation)
    local sin_r = math.sin(-self.rotation)
    local rx = dx * cos_r - dy * sin_r
    local ry = dx * sin_r + dy * cos_r

    -- Check if point is inside rectangle
    return math.abs(rx) < self.width / 2 and math.abs(ry) < self.height / 2
end

-- Select the card
function Card:select()
    self.isSelected = true
end

-- Deselect the card
function Card:deselect()
    self.isSelected = false
end

-- Hide the card
function Card:hide()
    self.isVisible = false
end

-- Show the card
function Card:show()
    self.isVisible = true
end

return Card
