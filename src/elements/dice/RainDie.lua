-- src/elements/dice/RainDie.lua

-- Constants
local RAIN_DIE_NAME = "Rain"            -- Die name
local RAIN_DIE_COLOR = "#99ccff"        -- Die background color
local RAIN_DIE_TEXT_COLOR = "#333333"   -- Die text color
local RAIN_MIN_VALUE = 0                -- Minimum value
local RAIN_MAX_VALUE = 6                -- Maximum value

-- Import base Die class
local Die = require("src/elements/dice/Die")

-- RainDie represents the rain die
local RainDie = setmetatable({}, {__index = Die})
RainDie.__index = RainDie

-- Constructor
function RainDie:new()
    local self = setmetatable(Die:new(RAIN_DIE_NAME, RAIN_MIN_VALUE, RAIN_MAX_VALUE), RainDie)
    
    -- Override die properties
    self.backgroundColor = RAIN_DIE_COLOR
    self.textColor = RAIN_DIE_TEXT_COLOR
    
    return self
end

-- Get season-adjusted range
function RainDie:getSeasonRange(season)
    if season == "Spring" then
        return 2, 6
    elseif season == "Summer" then
        return 0, 4
    elseif season == "Autumn" then
        return 1, 6
    elseif season == "Winter" then
        return 0, 4
    else
        return self.minValue, self.maxValue
    end
end

-- Roll with season adjustment
function RainDie:rollForSeason(season)
    local min, max = self:getSeasonRange(season)
    self.value = math.random(min, max)
    return self.value
end

-- Check if value causes drought
function RainDie:causesDrought()
    return self.value ~= nil and self.value == 0
end

return RainDie