-- src/elements/dice/SunDie.lua

-- Constants
local SUN_DIE_NAME = "Sun"              -- Die name
local SUN_DIE_COLOR = "#ffcc00"         -- Die background color
local SUN_DIE_TEXT_COLOR = "#333333"    -- Die text color
local SUN_MIN_VALUE = -3                -- Minimum value
local SUN_MAX_VALUE = 8                 -- Maximum value

-- Import base Die class
local Die = require("src/elements/dice/Die")

-- SunDie represents the sun die
local SunDie = setmetatable({}, {__index = Die})
SunDie.__index = SunDie

-- Constructor
function SunDie:new()
    local self = setmetatable(Die:new(SUN_DIE_NAME, SUN_MIN_VALUE, SUN_MAX_VALUE), SunDie)
    
    -- Override die properties
    self.backgroundColor = SUN_DIE_COLOR
    self.textColor = SUN_DIE_TEXT_COLOR
    
    return self
end

-- Get season-adjusted range
function SunDie:getSeasonRange(season)
    if season == "Spring" then
        return -1, 5
    elseif season == "Summer" then
        return 3, 8
    elseif season == "Autumn" then
        return -2, 4
    elseif season == "Winter" then
        return -3, 2
    else
        return self.minValue, self.maxValue
    end
end

-- Roll with season adjustment
function SunDie:rollForSeason(season)
    local min, max = self:getSeasonRange(season)
    self.value = math.random(min, max)
    return self.value
end

-- Check if value causes frost
function SunDie:causesFrost(freezeThreshold)
    return self.value ~= nil and self.value < freezeThreshold
end

return SunDie