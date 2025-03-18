-- Système de gestion des cartes
local Plant = require('src.entities.plant')
local GameConfig = require('src.utils.game_config')

local CardSystem = {}
CardSystem.__index = CardSystem

-- Utilisation des constantes centralisées
local CARD_WIDTH = GameConfig.UI.CARD.WIDTH
local CARD_HEIGHT = GameConfig.UI.CARD.HEIGHT

-- Le constructeur prend les dépendances via injection
function CardSystem.new(dependencies)
    local self = setmetatable({}, CardSystem)
    self.deck = {}
    self.hand = {}
    self.discardPile = {}
    
    -- Stocker les dépendances
    self.dependencies = dependencies or {}
    self.scaleManager = self.dependencies.scaleManager
    
    -- Initialisation du deck avec cartes de base
    self:initializeDeck()
    self:drawInitialHand()
    
    return self
end

function CardSystem:initializeDeck()
    -- Ajouter cartes Brassika
    for i = 1, 8 do
        table.insert(self.deck, {
            id = "brassika_" .. i,
            type = GameConfig.CARD_TYPE.PLANT,
            family = GameConfig.PLANT_FAMILY.BRASSIKA,
            color = {0.7, 0.85, 0.7}, -- Vert pâle
            sunToSprout = 3,
            rainToSprout = 4,
            sunToFruit = 6,
            rainToFruit = 8,
            frostThreshold = -5,
            baseScore = 20,
            width = CARD_WIDTH,
            height = CARD_HEIGHT,
            x = 0,
            y = 0
        })
    end
    
    -- Ajouter cartes Solana
    for i = 1, 7 do
        table.insert(self.deck, {
            id = "solana_" .. i,
            type = GameConfig.CARD_TYPE.PLANT,
            family = GameConfig.PLANT_FAMILY.SOLANA,
            color = {0.9, 0.7, 0.5}, -- Orange pâle
            sunToSprout = 5,
            rainToSprout = 3,
            sunToFruit = 10,
            rainToFruit = 6,
            frostThreshold = -2,
            baseScore = 30,
            width = CARD_WIDTH,
            height = CARD_HEIGHT,
            x = 0,
            y = 0
        })
    end
    
    -- Mélanger le deck
    self:shuffleDeck()
end

function CardSystem:shuffleDeck()
    for i = #self.deck, 2, -1 do
        local j = math.random(i)
        self.deck[i], self.deck[j] = self.deck[j], self.deck[i]
    end
end

function CardSystem:drawCard()
    if #self.deck == 0 then
        -- Recycler la défausse si le deck est vide
        self.deck = self.discardPile
        self.discardPile = {}
        self:shuffleDeck()
    end
    
    if #self.deck > 0 then
        local card = table.remove(self.deck)
        table.insert(self.hand, card)
        return card
    end
    return nil
end

function CardSystem:drawInitialHand()
    for i = 1, 5 do
        self:drawCard()
    end
end

function CardSystem:playCard(cardIndex, garden, x, y)
    if cardIndex <= 0 or cardIndex > #self.hand then
        return false
    end
    
    local card = self.hand[cardIndex]
    
    if card.type == GameConfig.CARD_TYPE.PLANT then
        local plant = Plant.new(card.family, card.color)
        if garden:placePlant(plant, x, y) then
            -- Retirer la carte de la main
            table.remove(self.hand, cardIndex)
            
            -- Ajouter la carte à la défausse
            table.insert(self.discardPile, card)
            
            return true
        end
    end
    
    return false
end

-- Getter pour récupérer la main
function CardSystem:getHand()
    return self.hand
end

-- Fonction pour savoir si un point est sur une carte
function CardSystem:getCardAt(x, y)
    for i = #self.hand, 1, -1 do -- Regarder de haut en bas
        local card = self.hand[i]
        if x >= card.x - CARD_WIDTH/2 and x <= card.x + CARD_WIDTH/2 and
           y >= card.y - CARD_HEIGHT/2 and y <= card.y + CARD_HEIGHT/2 then
            return card, i
        end
    end
    return nil
end

return CardSystem