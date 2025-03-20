-- src/core/GameState.lua

-- Constants
local DEFAULT_STATE = "menu"

-- GameState manages the different states of the game
local GameState = {}
GameState.__index = GameState

-- Constructor
function GameState:new()
    local self = setmetatable({}, GameState)
    
    -- Current game state
    self.currentState = DEFAULT_STATE
    
    -- Available game states
    self.states = {
        "menu",      -- Main menu
        "gameplay",  -- Active gameplay
        "pause",     -- Game paused
        "endRound"   -- End of round
    }
    
    return self
end

-- Change the current game state
function GameState:changeState(newState)
    -- Verify the state is valid
    for _, state in ipairs(self.states) do
        if state == newState then
            self.currentState = newState
            return true
        end
    end
    
    -- Invalid state
    return false
end

-- Get the current game state
function GameState:getCurrentState()
    return self.currentState
end

return GameState