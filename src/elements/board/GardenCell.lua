-- src/elements/board/GardenCell.lua

-- Constants
local CELL_DEFAULT_WIDTH = 70          -- Width of cell in pixels
local CELL_DEFAULT_HEIGHT = 70         -- Height of cell in pixels
local CELL_DEFAULT_COLOR = "#d0b090"   -- Default background color (empty cell)
local CELL_HIGHLIGHT_COLOR = "#f0d0a0" -- Highlight color when cell is hovered
local CELL_SELECTED_COLOR = "#ffd700"  -- Color when cell is selected
local CELL_BORDER_WIDTH = 2            -- Width of cell border
local CELL_CORNER_RADIUS = 4           -- Rounded corner radius
local CELL_PLANT_MARGIN = 5            -- Margin between plant and cell border

-- The GardenCell class represents a single cell in the garden grid
local GardenCell = {}
GardenCell.__index = GardenCell

-- Static method to get default cell size
function GardenCell.getDefaultSize()
    return CELL_DEFAULT_WIDTH, CELL_DEFAULT_HEIGHT
end

-- Constructor for a new garden cell
function GardenCell:new(localX, localY, gridX, gridY)
    local self = setmetatable({}, GardenCell)

    -- Position within parent garden
    self.localX = localX -- X position relative to garden
    self.localY = localY -- Y position relative to garden

    -- Absolute position on screen (set by Garden:setPosition)
    self.x = 0 -- X position on screen
    self.y = 0 -- Y position on screen

    -- Size
    self.width = CELL_DEFAULT_WIDTH   -- Width in pixels
    self.height = CELL_DEFAULT_HEIGHT -- Height in pixels

    -- Grid coordinates
    self.gridX = gridX -- X position in garden grid (1-based)
    self.gridY = gridY -- Y position in garden grid (1-based)

    -- Content
    self.plant = nil -- The plant in this cell (nil if empty)

    -- State
    self.isHovered = false  -- Whether mouse is currently over this cell
    self.isSelected = false -- Whether cell is currently selected

    -- Get color conversion utility
    self.color = require("utils/convertColor")

    return self
end

-- Set absolute position on screen
function GardenCell:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Update method called each frame
function GardenCell:update(dt)
    -- Update plant if present
    if self.plant then
        self.plant:update(dt)
    end

    -- Update hover state based on mouse position
    local mouseX, mouseY = love.mouse.getPosition()
    self.isHovered = self:containsPoint(mouseX, mouseY)
end

-- Draw the cell and its contents
function GardenCell:draw()
    -- Determine cell background color based on state
    if self.isSelected then
        love.graphics.setColor(self.color.hex(CELL_SELECTED_COLOR))
    elseif self.isHovered then
        love.graphics.setColor(self.color.hex(CELL_HIGHLIGHT_COLOR))
    else
        love.graphics.setColor(self.color.hex(CELL_DEFAULT_COLOR))
    end

    -- Draw cell background
    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.width,
        self.height,
        CELL_CORNER_RADIUS
    )

    -- Draw cell border
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.setLineWidth(CELL_BORDER_WIDTH)
    love.graphics.rectangle(
        "line",
        self.x,
        self.y,
        self.width,
        self.height,
        CELL_CORNER_RADIUS
    )

    -- Draw plant if present
    if self.plant then
        love.graphics.printf(self.plant.name, self.x, self.y + 5, self.width, "center")
    end

    -- Draw cell coordinates for debug
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.gridX .. "," .. self.gridY, self.x + 5, self.y + 5)

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Add a plant to this cell
function GardenCell:addPlant(plant)
    if not self.plant then
        self.plant = plant
        -- Position plant inside the cell with margin
        plant:setPosition(
            self.x + CELL_PLANT_MARGIN,
            self.y + CELL_PLANT_MARGIN,
            self.width - (CELL_PLANT_MARGIN * 2),
            self.height - (CELL_PLANT_MARGIN * 2)
        )
        return true
    end
    return false -- Cell already has a plant
end

-- Remove plant from this cell
function GardenCell:removePlant()
    local plant = self.plant
    self.plant = nil
    return plant
end

-- Check if point (x,y) is inside this cell
function GardenCell:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and
        y >= self.y and y <= self.y + self.height
end

-- Select this cell
function GardenCell:select()
    self.isSelected = true
end

-- Deselect this cell
function GardenCell:deselect()
    self.isSelected = false
end

-- Check if cell is empty (no plant)
function GardenCell:isEmpty()
    return self.plant == nil
end

function GardenCell:sowPlant(plant)
    print("Sowing plant " .. plant.name .. " in cell " .. self.gridX .. "," .. self.gridY)
    self.plant = plant
end

return GardenCell
