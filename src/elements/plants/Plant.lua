-- src/elements/plants/Plant.lua

-- Constants
local GROWTH_STATES = {"seed", "growing", "fruiting"}  -- Growth stages
local BASE_COLOR = "#c8e0c8"                         -- Base plant color
local FRUITING_COLOR = "#a0d0a0"                    -- Color when fruiting
local PLANT_BORDER_COLOR = "#666666"                -- Border color
local PLANT_BORDER_WIDTH = 1                        -- Border width
local PLANT_TEXT_COLOR = "#333333"                  -- Text color
local BASE_SUN_REQUIREMENT = 5                      -- Base sun points needed
local BASE_RAIN_REQUIREMENT = 6                     -- Base rain points needed
local BASE_SCORE = 20                               -- Base score when harvested

-- Plant base class for all plant types
local Plant = {}
Plant.__index = Plant

-- Constructor
function Plant:new(family, name)
    local self = setmetatable({}, Plant)
    
    -- Basic properties
    self.family = family or "generic"     -- Plant family
    self.name = name or "Plant"          -- Plant name
    
    -- Position and size
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
    
    -- Growth properties
    self.growthState = GROWTH_STATES[1]   -- Start as seed
    self.growthIndex = 1                  -- Index in growth states
    
    -- Resource requirements
    self.sunRequired = BASE_SUN_REQUIREMENT
    self.rainRequired = BASE_RAIN_REQUIREMENT
    
    -- Current accumulated resources
    self.sunAccumulated = 0
    self.rainAccumulated = 0
    
    -- Scoring
    self.baseScore = BASE_SCORE
    
    -- Get color conversion utility
    self.color = require("utils/convertColor")
    
    return self
end

-- Set the plant's position in the cell
function Plant:setPosition(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width or 60
    self.height = height or 60
end

-- Update plant state
function Plant:update(dt)
    -- Check if ready to advance growth state
    if self.sunAccumulated >= self.sunRequired and 
       self.rainAccumulated >= self.rainRequired and
       self.growthIndex < #GROWTH_STATES then
        
        -- Advance to next growth state
        self.growthIndex = self.growthIndex + 1
        self.growthState = GROWTH_STATES[self.growthIndex]
        
        -- Reset accumulated resources
        self.sunAccumulated = 0
        self.rainAccumulated = 0
    end
end

-- Draw the plant
function Plant:draw()
    -- Determine color based on growth state
    local fillColor = BASE_COLOR
    if self.growthState == "fruiting" then
        fillColor = FRUITING_COLOR
    end
    
    -- Draw plant background
    love.graphics.setColor(self.color.hex(fillColor))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw plant border
    love.graphics.setColor(self.color.hex(PLANT_BORDER_COLOR))
    love.graphics.setLineWidth(PLANT_BORDER_WIDTH)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw plant info
    love.graphics.setColor(self.color.hex(PLANT_TEXT_COLOR))
    
    -- Plant name
    love.graphics.printf(self.name, self.x + 5, self.y + 5, self.width - 10, "left")
    
    -- Growth state
    love.graphics.printf(self.growthState, self.x + 5, self.y + 25, self.width - 10, "left")
    
    -- Resource info
    local resourceText = string.format("☀️ %d/%d 🌧️ %d/%d", 
        self.sunAccumulated, self.sunRequired,
        self.rainAccumulated, self.rainRequired)
    love.graphics.printf(resourceText, self.x + 5, self.y + 40, self.width - 10, "left")
    
    -- Score if fruiting
    if self.growthState == "fruiting" then
        love.graphics.printf(self.baseScore .. " pts", self.x + 5, self.y + 55, self.width - 10, "center")
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Add sun points to the plant
function Plant:addSun(amount)
    self.sunAccumulated = self.sunAccumulated + amount
end

-- Add rain points to the plant
function Plant:addRain(amount)
    self.rainAccumulated = self.rainAccumulated + amount
end

-- Check if plant is ready to harvest
function Plant:isHarvestable()
    return self.growthState == "fruiting"
end

-- Get score for harvesting
function Plant:getScore()
    if self:isHarvestable() then
        return self.baseScore
    else
        return 0
    end
end

return Plant