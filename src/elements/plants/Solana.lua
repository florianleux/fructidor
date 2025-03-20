-- src/elements/plants/Solana.lua

-- Constants
local SOLANA_NAME = "Solana"                 -- Display name
local SOLANA_COLOR = "#e88c38"               -- Plant color
local SOLANA_FRUITING_COLOR = "#d07030"      -- Color when fruiting
local SOLANA_SUN_REQUIREMENT = 6             -- Sun points needed
local SOLANA_RAIN_REQUIREMENT = 4            -- Rain points needed
local SOLANA_FREEZE_THRESHOLD = -2           -- Temperature below which plant freezes
local SOLANA_BASE_SCORE = 28                 -- Base score when harvested

-- Import Plant base class
local Plant = require("src/elements/plants/Plant")

-- Solana subclass
local Solana = setmetatable({}, {__index = Plant})
Solana.__index = Solana

-- Constructor
function Solana:new()
    local self = setmetatable(Plant:new("solana", SOLANA_NAME), Solana)
    
    -- Override plant properties
    self.sunRequired = SOLANA_SUN_REQUIREMENT
    self.rainRequired = SOLANA_RAIN_REQUIREMENT
    self.freezeThreshold = SOLANA_FREEZE_THRESHOLD
    self.baseScore = SOLANA_BASE_SCORE
    
    return self
end

-- Override draw method to use Solana-specific colors
function Solana:draw()
    -- Store original colors
    local originalBaseColor = BASE_COLOR
    local originalFruitingColor = FRUITING_COLOR
    
    -- Set Solana-specific colors
    BASE_COLOR = SOLANA_COLOR
    FRUITING_COLOR = SOLANA_FRUITING_COLOR
    
    -- Call parent draw method
    Plant.draw(self)
    
    -- Restore original colors
    BASE_COLOR = originalBaseColor
    FRUITING_COLOR = originalFruitingColor
end

-- Override addSun to give bonus for Solana
function Solana:addSun(amount)
    -- Solana gets +1 bonus for sun
    Plant.addSun(self, amount + 1)
end

return Solana