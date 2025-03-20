-- src/elements/board/Round.lua

-- Constants
local ROUND_PHASES = {"start", "action", "resolution", "end"}  -- Phases within a round

-- Round represents a single game round
local Round = {}
Round.__index = Round

-- Constructor
function Round:new(number, season)
    local self = setmetatable({}, Round)
    
    -- Basic properties
    self.number = number or 1        -- Round number (1-8)
    self.season = season or "Spring"  -- Season (Spring, Summer, Autumn, Winter)
    
    -- Round state
    self.phase = ROUND_PHASES[1]     -- Current phase
    self.phaseIndex = 1              -- Index in phases array
    
    -- Weather values for this round
    self.sunValue = 0                -- Sun value (set in resolution phase)
    self.rainValue = 0               -- Rain value (set in resolution phase)
    
    return self
end

-- Advance to next phase
function Round:nextPhase()
    if self.phaseIndex < #ROUND_PHASES then
        self.phaseIndex = self.phaseIndex + 1
        self.phase = ROUND_PHASES[self.phaseIndex]
        return true
    end
    return false  -- Already at last phase
end

-- Set weather values
function Round:setWeather(sunValue, rainValue)
    self.sunValue = sunValue
    self.rainValue = rainValue
end

-- Get sun constraints based on season
function Round:getSunRange()
    if self.season == "Spring" then
        return -1, 5  -- Min, Max
    elseif self.season == "Summer" then
        return 3, 8
    elseif self.season == "Autumn" then
        return -2, 4
    elseif self.season == "Winter" then
        return -3, 2
    end
end

-- Get rain constraints based on season
function Round:getRainRange()
    if self.season == "Spring" then
        return 2, 6  -- Min, Max
    elseif self.season == "Summer" then
        return 0, 4
    elseif self.season == "Autumn" then
        return 1, 6
    elseif self.season == "Winter" then
        return 0, 4
    end
end

-- Get frost risk based on season
function Round:getFrostRisk()
    if self.season == "Spring" then
        return "Low"
    elseif self.season == "Summer" then
        return "None"
    elseif self.season == "Autumn" then
        return "Medium"
    elseif self.season == "Winter" then
        return "High"
    end
end

-- Check if this round is in a specific season
function Round:isSeason(seasonName)
    return self.season == seasonName
end

return Round