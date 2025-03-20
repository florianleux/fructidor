-- src/elements/cards/Deck.lua

-- Constants
local INITIAL_DECK_SIZE = 20      -- Initial number of cards in deck
local DEFAULT_BRASSIKA_COUNT = 12 -- Number of Brassika cards
local DEFAULT_SOLANA_COUNT = 8    -- Number of Solana cards

-- Deck represents the player's collection of cards
local Deck = {}
Deck.__index = Deck

-- Import dependencies
local Card = require("src/elements/cards/Card")

-- Constructor
function Deck:new()
    local self = setmetatable({}, Deck)

    -- Deck properties
    self.cards = {} -- Cards in the deck

    -- Initialize deck with starter cards
    self:initializeStarterDeck()

    -- Shuffle the deck
    self:shuffle()

    return self
end

-- Initialize the starter deck
function Deck:initializeStarterDeck()
    -- Add Brassika cards
    for i = 1, DEFAULT_BRASSIKA_COUNT do
        table.insert(self.cards, Card:new("plant", "brassika", "Brassika"))
    end

    -- Add Solana cards
    for i = 1, DEFAULT_SOLANA_COUNT do
        table.insert(self.cards, Card:new("plant", "solana", "Solana"))
    end
end

-- Shuffle the deck
function Deck:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

-- Draw a card from the deck
function Deck:drawCard()
    if #self.cards > 0 then
        return table.remove(self.cards)
    else
        return nil -- No cards left
    end
end

-- Get number of cards in deck
function Deck:getCount()
    return #self.cards
end

-- Add a card to the top of the deck
function Deck:addToTop(card)
    table.insert(self.cards, card)
end

-- Add a card to the bottom of the deck
function Deck:addToBottom(card)
    table.insert(self.cards, 1, card)
end

return Deck
