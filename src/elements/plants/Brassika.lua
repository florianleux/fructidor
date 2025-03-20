-- src/elements/plants/Brassika.lua

-- Constants
local BRASSIKA_NAME = "Brassika"             -- Display name
local BRASSIKA_COLOR = "#b8d868"             -- Plant color
local BRASSIKA_FRUITING_COLOR = "#a0c850"    -- Color when fruiting
local BRASSIKA_SUN_REQUIREMENT = 3           -- Sun points needed
local BRASSIKA_RAIN_REQUIREMENT = 5          -- Rain points needed
local BRASSIKA_FREEZE_THRESHOLD = -4         -- Temperature below which plant freezes
local BRASSIKA_BASE_SCORE = 18               -- Base score when harvested

-- Import Plant base class
local Plant = require("src/elements/plants/Plant")

-- Brassika subclass
local Brassika = setmetatable({}, {__index = Plant})
Brassika.__index = Brassika

-- Constructor
function Brassika:new()
    local self = setmetatable(Plant:new("brassika", BRASSIKA_NAME), Brassika)
    
    -- Override plant properties
    self.sunRequired = BRASSIKA_SUN_REQUIREMENT
    self.rainRequired = BRASSIKA_RAIN_REQUIREMENT
    self.freezeThreshold = BRASSIKA_FREEZE_THRESHOLD
    self.baseScore = BRASSIKA_BASE_SCORE
    
    return self
end

-- Override draw method to use Brassika-specific colors
function Brassika:draw()
    -- Store original colors
    local originalBaseColor = BASE_COLOR
    local originalFruitingColor = FRUITING_COLOR
    
    -- Set Brassika-specific colors
    BASE_COLOR = BRASSIKA_COLOR
    FRUITING_COLOR = BRASSIKA_FRUITING_COLOR
    
    -- Call parent draw method
    Plant.draw(self)
    
    -- Restore original colors
    BASE_COLOR = originalBaseColor
    FRUITING_COLOR = originalFruitingColor
end

-- Check if plant can survive current temperature
function Brassika:canSurviveTemperature(temperature)
    return temperature >= self.freezeThreshold
end

return Brassika