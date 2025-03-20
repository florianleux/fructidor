local GameStateComponent = Class('GameStateComponent')

function GameStateComponent:initialize(state)
    self.state = state or {
        currentTurn = 1,
        garden = {},
        deck = {},
        hand = {}
    }
    
    if not self.state.garden then self.state.garden = {} end
    
    -- Initialize deck with starter cards if empty
    if not self.state.deck or #self.state.deck == 0 then
        self.state.deck = self:createStarterDeck()
    end
    
    -- Initialize hand with cards from deck if empty
    if not self.state.hand or #self.state.hand == 0 then
        self.state.hand = {}
        for i = 1, math.min(5, #self.state.deck) do
            table.insert(self.state.hand, table.remove(self.state.deck, 1))
        end
    end
end

function GameStateComponent:createStarterDeck()
    local deck = {}
    
    -- Add some basic plant cards
    for i = 1, 3 do
        table.insert(deck, {
            id = "brassika_" .. i,
            type = "plant",
            family = "Brassika",
            name = "Brassika",
            color = "Green"
        })
    end
    
    for i = 1, 2 do
        table.insert(deck, {
            id = "solana_" .. i,
            type = "plant",
            family = "Solana",
            name = "Solana",
            color = "Red"
        })
    end
    
    -- Add some object cards
    table.insert(deck, {
        id = "paillage_1",
        type = "object",
        name = "Paillage",
        objectType = "combinable"
    })
    
    table.insert(deck, {
        id = "tuteur_1",
        type = "object",
        name = "Tuteur",
        objectType = "combinable"
    })
    
    -- Shuffle the deck
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    
    return deck
end

return GameStateComponent