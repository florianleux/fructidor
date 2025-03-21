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
    
    -- État pour le drag & drop
    self.dragState = {
        isDragging = false,
        card = nil,
        originalX = 0,
        originalY = 0,
        originalRotation = 0
    }

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
    self.roundBoard:draw()
    self.sunDie:draw()
    self.rainDie:draw()
    self.scoreBoard:draw()
    
    -- Draw cards en main - on les dessine à la fin pour qu'elles apparaissent au-dessus
    self.cardHand:draw()
end

-- Gérer les événements de mouvement de souris
function GameLevel:mousemoved(x, y, dx, dy)
    if not self.isActive or not self.dragState.isDragging then return end
    
    -- Mettre à jour la position de la carte en cours de déplacement
    self.dragState.card:setPosition(x, y)
    
    -- Garder la carte droite pendant le déplacement
    self.dragState.card:setRotation(0)
end

-- Handle mouse press events
function GameLevel:mousepressed(x, y, button)
    if not self.isActive then return end

    -- D'abord vérifier si on clique sur une carte (priorité la plus haute)
    local clickedCard = nil
    
    -- Parcourir les cartes en main dans l'ordre inverse (top-to-bottom)
    for i = #self.cardHand.cards, 1, -1 do
        local card = self.cardHand.cards[i]
        if card:containsPoint(x, y) then
            clickedCard = card
            break
        end
    end
    
    -- Si une carte est cliquée, commencer le drag
    if clickedCard then
        -- Sauvegarder l'état initial
        self.dragState.isDragging = true
        self.dragState.card = clickedCard
        self.dragState.originalX = clickedCard.x
        self.dragState.originalY = clickedCard.y
        self.dragState.originalRotation = clickedCard.rotation
        
        -- Déselectionner la carte précédente si elle existe
        if self.cardHand.selectedCard and self.cardHand.selectedCard ~= clickedCard then
            self.cardHand.selectedCard:deselect()
        end
        
        -- Sélectionner cette carte
        clickedCard:select()
        self.cardHand.selectedCard = clickedCard
        
        return -- La carte a absorbé le clic, ne pas traiter les autres éléments
    end

    -- Si on n'a pas cliqué sur une carte, vérifier les autres éléments
    self.garden:mousepressed(x, y, button)
    self.sunDie:mousepressed(x, y, button)
    self.rainDie:mousepressed(x, y, button)
    self.roundBoard:mousepressed(x, y, button)
end

-- Handle mouse release events
function GameLevel:mousereleased(x, y, button)
    if not self.isActive then return end

    -- Si on relâche pendant un drag
    if self.dragState.isDragging then
        -- Vérifier si on a relâché sur une cellule du jardin
        local targetCell = self.garden:getCellAtPosition(x, y)
        
        if targetCell and targetCell:isEmpty() and self.dragState.card.type == "plant" then
            -- Placer la carte/plante dans la cellule
            -- 1. Enlever la carte de la main
            self.cardHand:removeCard(self.dragState.card)
            
            -- 2. Créer une plante correspondante
            local plantType = self.dragState.card.family
            local Plant = nil
            
            -- Charger le type de plante approprié
            if plantType == "brassika" then
                Plant = require("src/elements/plants/Brassika")
            elseif plantType == "solana" then
                Plant = require("src/elements/plants/Solana")
            else
                -- Type inconnu, utiliser le type générique
                Plant = require("src/elements/plants/Plant")
            end
            
            -- Créer une nouvelle plante
            local newPlant = Plant:new()
            
            -- Ajouter la plante à la cellule
            targetCell:addPlant(newPlant)
            
            -- Sélectionner la cellule
            if self.garden.selectedCell then
                self.garden.selectedCell:deselect()
            end
            targetCell:select()
            self.garden.selectedCell = targetCell
        else
            -- Retourner la carte à sa position d'origine
            self.dragState.card:setPosition(self.dragState.originalX, self.dragState.originalY)
            self.dragState.card:setRotation(self.dragState.originalRotation)
        end
        
        -- Réinitialiser l'état de drag
        self.dragState.isDragging = false
        self.dragState.card = nil
        
        return -- Le drag est terminé, ne pas traiter les autres éléments
    end
    
    -- Comportement normal si pas de drag
    self.garden:mousereleased(x, y, button)
    self.cardHand:mousereleased(x, y, button)
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