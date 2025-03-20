local GameStateComponent = Class('GameStateComponent')

function GameStateComponent:initialize(state)
    self.state = state or {
        currentTurn = 1,
        garden = {},
        deck = {},
        hand = {}
    }
    
    if not self.state.garden then self.state.garden = {} end
    if not self.state.deck then self.state.deck = {} end
    if not self.state.hand then self.state.hand = {} end
end

return GameStateComponent