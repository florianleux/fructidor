-- src/elements/board/Garden.lua

-- Constants
local DEFAULT_GRID_WIDTH = 3
local DEFAULT_GRID_HEIGHT = 2
local GRID_SPACING = 5  -- Space between cells
local GARDEN_BACKGROUND_COLOR = "#e8d0b0"  -- Light brown background
local GARDEN_BORDER_COLOR = "#966f33"  -- Darker brown border
local GARDEN_BORDER_WIDTH = 3
local GARDEN_CORNER_RADIUS = 8
local GARDEN_PADDING = 15  -- Padding around the grid

-- Import dependencies
local GardenCell = require("src/elements/board/GardenCell")
local color = require("utils/convertColor")

-- Garden manages a grid of cells
local Garden = {}
Garden.__index = Garden

-- Constructor
function Garden:new(width, height)
    local self = setmetatable({}, Garden)
    
    -- Grid dimensions
    self.gridWidth = width or DEFAULT_GRID_WIDTH
    self.gridHeight = height or DEFAULT_GRID_HEIGHT
    
    -- Position and size
    self.x = 0
    self.y = 0
    self.width = 0  -- Will be calculated based on cell size
    self.height = 0  -- Will be calculated based on cell size
    
    -- Grid cells
    self.cells = {}
    
    -- Selected cell
    self.selectedCell = nil
    
    -- Create garden cells
    self:createCells()
    
    return self
end

-- Create the grid cells
function Garden:createCells()
    -- Get cell size
    local cellWidth, cellHeight = GardenCell.getDefaultSize()
    
    -- Calculate garden size based on cells and spacing
    self.width = (cellWidth * self.gridWidth) + (GRID_SPACING * (self.gridWidth - 1)) + (GARDEN_PADDING * 2)
    self.height = (cellHeight * self.gridHeight) + (GRID_SPACING * (self.gridHeight - 1)) + (GARDEN_PADDING * 2)
    
    -- Create cells
    for y = 1, self.gridHeight do
        for x = 1, self.gridWidth do
            -- Calculate cell position within garden
            local cellX = GARDEN_PADDING + (x - 1) * (cellWidth + GRID_SPACING)
            local cellY = GARDEN_PADDING + (y - 1) * (cellHeight + GRID_SPACING)
            
            -- Create and store the cell
            local cell = GardenCell:new(cellX, cellY, x, y)
            table.insert(self.cells, cell)
        end
    end
end

-- Position the garden on screen
function Garden:setPosition(x, y)
    -- Store the position
    self.x = x - self.width / 2  -- Center horizontally
    self.y = y - self.height / 2  -- Center vertically
    
    -- Update cell positions
    for _, cell in ipairs(self.cells) do
        cell:setPosition(self.x + cell.localX, self.y + cell.localY)
    end
end

-- Get cell at specific grid coordinates
function Garden:getCellAt(gridX, gridY)
    for _, cell in ipairs(self.cells) do
        if cell.gridX == gridX and cell.gridY == gridY then
            return cell
        end
    end
    return nil
end

-- Find cell containing screen coordinates
function Garden:getCellAtPosition(x, y)
    for _, cell in ipairs(self.cells) do
        if cell:containsPoint(x, y) then
            return cell
        end
    end
    return nil
end

-- Update the garden and cells
function Garden:update(dt)
    for _, cell in ipairs(self.cells) do
        cell:update(dt)
    end
end

-- Draw the garden and cells
function Garden:draw()
    -- Draw garden background
    love.graphics.setColor(color.hex(GARDEN_BACKGROUND_COLOR))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, GARDEN_CORNER_RADIUS)
    
    -- Draw garden border
    love.graphics.setColor(color.hex(GARDEN_BORDER_COLOR))
    love.graphics.setLineWidth(GARDEN_BORDER_WIDTH)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, GARDEN_CORNER_RADIUS)
    
    -- Draw cells
    for _, cell in ipairs(self.cells) do
        cell:draw()
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Handle mouse press event
function Garden:mousepressed(x, y, button)
    -- Check if press is inside garden
    if x >= self.x and x <= self.x + self.width and 
       y >= self.y and y <= self.y + self.height then
        
        -- Find the cell that was clicked
        local cell = self:getCellAtPosition(x, y)
        if cell then
            -- Deselect previous cell if any
            if self.selectedCell then
                self.selectedCell:deselect()
            end
            
            -- Select this cell
            cell:select()
            self.selectedCell = cell
        end
    end
end

-- Handle mouse release event
function Garden:mousereleased(x, y, button)
    -- To be implemented later for drag & drop
end

return Garden