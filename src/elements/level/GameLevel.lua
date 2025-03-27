-- src/elements/level/GameLevel.lua

-- Constants
local DEFAULT_DIFFICULTY = "normal" -- Default difficulty level
local TARGET_SCORES = {             -- Target scores for different difficulties
    easy = 80,
    normal = 100,
    hard = 120
}

-- GameLevel contains all elements of a playable level
local GameLevel = {}
GameLevel.__index = GameLevel

-- Import components
local Garden = require("src/elements/board/Garden")
local CardHand = require("src/elements/cards/CardHand")
local Deck = require("src/elements/cards/Deck")
local RoundBoard = require("src/elements/board/RoundBoard")
local ScoreBoard = require("src/elements/board/ScoreBoard")
local SunDie = require("src/elements/dice/SunDie")
local RainDie = require("src/elements/dice/RainDie")

-- Constructor
function GameLevel:new()
    local self = setmetatable({}, GameLevel)

    -- Level components
    self.garden = nil
    self.cardHand = nil
    self.deck = nil
    self.roundBoard = nil
    self.scoreBoard = nil
    self.sunDie = nil
    self.rainDie = nil

    -- Level state
    self.isActive = false
    self.difficulty = DEFAULT_DIFFICULTY

    return self
end

-- Initialize level components
function GameLevel:initialize(difficulty)
    self.difficulty = difficulty or DEFAULT_DIFFICULTY

    -- Create level components
    self.garden = Garden:new(3, 2)  -- 3x2 grid
    self.cardHand = CardHand:new(5) -- 5 cards max
    self.deck = Deck:new()
    self.roundBoard = RoundBoard:new()
    self.scoreBoard = ScoreBoard:new()
    self.sunDie = SunDie:new()
    self.rainDie = RainDie:new()

    -- Set target score based on difficulty
    local targetScore = TARGET_SCORES[self.difficulty] or TARGET_SCORES.normal
    self.scoreBoard:setTarget(targetScore)

    -- Deal initial cards
    self.cardHand:drawCards(self.deck, 5)

    -- Activate level
    self.isActive = true
end

-- Position components on screen
function GameLevel:setPosition(width, height)
    -- Center the garden
    self.garden:setPosition(width / 2, height / 2)

    -- Place score in top left
    self.scoreBoard:setPosition(20, 20)

    -- Place round board in top center
    self.roundBoard:setPosition(width / 2, 50)

    -- Place dice below round board
    self.sunDie:setPosition(width / 2 - 60, 180)
    self.rainDie:setPosition(width / 2 + 60, 180)

    -- Place card hand at bottom
    self.cardHand:setPosition(width / 2, height)
end

-- Update level components
function GameLevel:update(dt)
    if not self.isActive then return end

    -- Update all components
    self.garden:update(dt)
    self.cardHand:update(dt)
    self.roundBoard:update(dt)
    self.sunDie:update(dt)
    self.rainDie:update(dt)
    self.scoreBoard:update(dt)

    -- Check if level is completed
    if self.scoreBoard:isTargetReached() then
        -- Handle level completion
    end
end

-- Draw level components
function GameLevel:draw()
    if not self.isActive then return end

    -- Draw all components
    self.garden:draw()
    self.cardHand:draw()
    self.roundBoard:draw()
    self.sunDie:draw()
    self.rainDie:draw()
    self.scoreBoard:draw()
end

-- Handle mouse press events with priority order
function GameLevel:mousepressed(x, y, button)
    if not self.isActive then return end

    -- Établir l'ordre de priorité pour les événements
    local handled = false

    -- 1. Vérifier d'abord les cartes en main (plus haute priorité)
    for i = #self.cardHand.cards, 1, -1 do
        local card = self.cardHand.cards[i]
        if card:containsPoint(x, y) then
            -- Sélectionner cette carte
            if self.cardHand.selectedCard then
                self.cardHand.selectedCard:deselect()
            end
            card:select()
            self.cardHand.selectedCard = card
            handled = true
            break
        end
    end

    -- 2. Si aucune carte n'a capté l'événement, passer aux cellules du jardin
    if not handled then
        local cell = self.garden:getCellAtPosition(x, y)
        if cell then
            if self.garden.selectedCell then
                self.garden.selectedCell:deselect()
            end
            cell:select()
            self.garden.selectedCell = cell
            handled = true
        end
    end

    -- 3. Vérifier les autres composants en ordre de priorité décroissante
    if not handled then
        if self.sunDie:mousepressed(x, y, button) then
            handled = true
        end
    end

    if not handled then
        if self.rainDie:mousepressed(x, y, button) then
            handled = true
        end
    end

    -- Dernier élément vérifié
    if not handled then
        self.roundBoard:mousepressed(x, y, button)
    end
end

-- Handle mouse move events with priority order
function GameLevel:mousemoved(x, y, dx, dy)
    if not self.isActive then return end

    -- Mise à jour des états de hover des différents composants
    -- Note: ici nous permettons à plusieurs composants de réagir au mouvement
    -- car il s'agit principalement d'effets visuels (hover)

    -- Mettre à jour hover des cartes
    for _, card in ipairs(self.cardHand.cards) do
        card.isHovered = card:containsPoint(x, y)
        if card.isSelected and card.isHovered then card:move(dx, dy) end
    end

    -- Mettre à jour hover des cellules
    for _, cell in ipairs(self.garden.cells) do
        cell.isHovered = cell:containsPoint(x, y)
    end

    -- Laisser les autres composants traiter le mouvement
    -- pour leurs propres effets visuels
    self.sunDie:update(0) -- Utilise update pour actualiser l'état hover
    self.rainDie:update(0)
end

-- Handle mouse release events with priority order
function GameLevel:mousereleased(x, y, button)
    if not self.isActive then return end

    local handled = false

    -- 1. Vérifier les cartes
    if self.cardHand.selectedCard then
        -- Verifier si on dépose une carte sur une cellule du potager
        if not handled then
            local cell = self.garden:getCellAtPosition(x, y)
            if cell then
                cell:sowPlant(self.cardHand.selectedCard)
                self.cardHand.selectedCard:sowCard()
                handled = true
            end
        else
            -- Logique de sélection/désélection uniquement
            self.cardHand.selectedCard:deselect()
            self.cardHand.selectedCard = nil
            handled = true
        end
    end



    -- 3. Traiter les autres composants
    if not handled then
        if self.sunDie:containsPoint(x, y) then
            self.sunDie:mousereleased(x, y, button)
            handled = true
        end
    end

    if not handled then
        if self.rainDie:containsPoint(x, y) then
            self.rainDie:mousereleased(x, y, button)
            handled = true
        end
    end

    if not handled then
        self.roundBoard:mousereleased(x, y, button)
    end
end

-- Advance to next round
function GameLevel:nextRound()
    if not self.isActive then return end

    -- Get current round before advancing
    local currentRound = self.roundBoard:getCurrentRound()

    -- Advance round board
    local nextRound = self.roundBoard:nextRound()
    if not nextRound then
        -- No more rounds, end level
        self.isActive = false
        return false
    end

    -- Roll dice for new round
    local season = nextRound.season
    self.sunDie:rollForSeason(season)
    self.rainDie:rollForSeason(season)

    -- Draw a new card
    local card = self.deck:drawCard()
    if card then
        self.cardHand:addCard(card)
    end

    return true
end

return GameLevel
