-- src/elements/cards/CardHand.lua

-- Constants
local MAX_CARDS = 7                    -- Maximum cards in hand
local CARD_SPACING = 30                -- Horizontal spacing between cards
local CARD_ARC_RADIUS = 400            -- Radius of the arc for card layout
local CARD_ARC_ANGLE = math.pi / 4     -- Angle of the arc (45 degrees)
local CARD_ROTATION_MAX = math.pi / 12 -- Maximum card rotation (15 degrees)
local CARD_Y_FACTOR = 8                -- Facteur de réduction pour la position Y (évite de placer les cartes trop haut)

-- CardHand manages the player's current hand of cards
local CardHand = {}
CardHand.__index = CardHand


-- Constructor
function CardHand:new(maxCards)
    local self = setmetatable({}, CardHand)

    -- Hand properties
    self.maxCards = maxCards or MAX_CARDS
    self.cards = {}

    -- Position
    self.x = 0
    self.y = 0

    -- Selected card
    self.selectedCard = nil

    return self
end

-- Set hand position
function CardHand:setPosition(x, y)
    self.x = x
    self.y = y

    -- Update card positions
    self:arrangeCards()
end

-- Add a card to the hand
function CardHand:addCard(card)
    if #self.cards < self.maxCards then
        table.insert(self.cards, card)
        self:arrangeCards()
        return true
    end
    return false
end

-- Remove a card from the hand
function CardHand:removeCard(card)
    for i, c in ipairs(self.cards) do
        if c == card then
            table.remove(self.cards, i)
            self:arrangeCards()
            return c
        end
    end
    return nil
end

-- Arrange cards in an arc
function CardHand:arrangeCards()
    local numCards = #self.cards
    if numCards <= 0 then
        return
    end

    -- Calculate angle between cards
    local angleStep = CARD_ARC_ANGLE / numCards

    -- Calculate starting angle
    local startAngle = -CARD_ARC_ANGLE / 2

    -- Position each card along the arc
    for i, card in ipairs(self.cards) do
        local angle = startAngle + (i - 1) * angleStep

        -- Calculate position on arc
        local cardX = self.x + math.sin(angle) * CARD_ARC_RADIUS
        -- Réduction du facteur vertical pour garder les cartes plus proches de self.y
        local cardY = self.y - math.cos(angle) * (CARD_ARC_RADIUS / CARD_Y_FACTOR)

        -- Position card
        card:setPosition(cardX, cardY)

        -- Rotate card to face outward from arc center
        card:setRotation(angle)
    end
end

-- Draw cards from deck
function CardHand:drawCards(deck, count)
    count = math.min(count, self.maxCards - #self.cards)

    for i = 1, count do
        local card = deck:drawCard()
        if card then
            self:addCard(card)
        else
            break -- No more cards in deck
        end
    end
end

-- Draw hand
function CardHand:draw()
    -- Draw each card from bottom to top
    for i = 1, #self.cards do
        self.cards[i]:draw()
    end
end

-- Update hand state
function CardHand:update(dt)
    for _, card in ipairs(self.cards) do
        card:update(dt)
    end
end

-- Handle mouse press
function CardHand:mousepressed(x, y, button)
    -- Check cards in reverse order (top to bottom)
    for i = #self.cards, 1, -1 do
        local card = self.cards[i]
        if card:containsPoint(x, y) then
            -- Deselect previous card if any
            if self.selectedCard and self.selectedCard ~= card then
                self.selectedCard:deselect()
            end

            -- Select this card
            card:select()
            card:mousepressed(x, y, button)
            self.selectedCard = card

            -- Bring card to front by reordering array
            table.remove(self.cards, i)
            table.insert(self.cards, card)

            return true
        end
    end
    return false
end

-- Handle mouse release
function CardHand:mousereleased(x, y, button)
    if self.selectedCard then
        self.selectedCard:mousereleased(x, y, button)
        
        -- Re-arrange cards after drag and drop
        self:arrangeCards()
        
        return true
    end
    return false
end

return CardHand
