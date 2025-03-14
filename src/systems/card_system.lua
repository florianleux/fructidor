-- Système de gestion des cartes
local Plant = require('src.entities.plant')

local CardSystem = {}
CardSystem.__index = CardSystem

function CardSystem.new()
    local self = setmetatable({}, CardSystem)
    self.deck = {}
    self.hand = {}
    self.discardPile = {}
    
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
            type = "plant",
            family = "Brassika",
            color = {0.7, 0.85, 0.7}, -- Vert pâle
            sunToSprout = 3,
            rainToSprout = 4,
            sunToFruit = 6,
            rainToFruit = 8,
            frostThreshold = -5,
            baseScore = 20,
            width = 60,
            height = 100,
            x = 0,
            y = 0
        })
    end
    
    -- Ajouter cartes Solana
    for i = 1, 7 do
        table.insert(self.deck, {
            id = "solana_" .. i,
            type = "plant",
            family = "Solana",
            color = {0.9, 0.7, 0.5}, -- Orange pâle
            sunToSprout = 5,
            rainToSprout = 3,
            sunToFruit = 10,
            rainToFruit = 6,
            frostThreshold = -2,
            baseScore = 30,
            width = 60,
            height = 100,
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
    
    if card.type == "plant" then
        local plant = Plant.new(card.family, card.color)
        if garden:placePlant(plant, x, y) then
            table.remove(self.hand, cardIndex)
            table.insert(self.discardPile, card)
            return true
        end
    end
    
    return false
end

-- Fonction pour AFFICHER une carte (renommer pour éviter conflit)
function CardSystem:renderCard(card, xPos, yPos)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", xPos - 30, yPos - 50, 60, 100, 3)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("line", xPos - 30, yPos - 50, 60, 100, 3)
    
    -- Couleur de fond selon la famille
    if card.color then
        love.graphics.setColor(card.color)
    else
        love.graphics.setColor(0.7, 0.7, 0.7)
    end
    love.graphics.rectangle("fill", xPos - 25, yPos - 45, 50, 15)
    
    -- Nom et info
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(card.family, xPos - 25, yPos - 45)
    love.graphics.print("Graine", xPos - 25, yPos - 25)
    
    -- Besoins pour pousser
    love.graphics.print("☀️ " .. card.sunToSprout, xPos - 25, yPos - 5)
    love.graphics.print("🌧️ " .. card.rainToSprout, xPos - 25, yPos + 10)
    
    -- Score
    love.graphics.print(card.baseScore .. " pts", xPos - 25, yPos + 25)
    
    -- Gel
    love.graphics.print("❄️ " .. card.frostThreshold, xPos - 25, yPos + 40)
end

-- Fonction pour dessiner la main du joueur
function CardSystem:drawHand()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local handY = screenHeight - 70
    
    -- Calculer la position des cartes en arc
    for i, card in ipairs(self.hand) do
        local angle = (i - (#self.hand + 1) / 2) * 0.1
        local x = screenWidth / 2 + angle * 200
        local y = handY + math.abs(angle) * 50
        
        -- Stocker la position pour le drag & drop
        card.x = x
        card.y = y
        
        -- Dessiner la carte
        self:renderCard(card, x, y)
    end
end

-- Fonction pour savoir si un point est sur une carte
function CardSystem:getCardAt(x, y)
    for i = #self.hand, 1, -1 do -- Regarder de haut en bas
        local card = self.hand[i]
        if x >= card.x - 30 and x <= card.x + 30 and
           y >= card.y - 50 and y <= card.y + 50 then
            return card, i
        end
    end
    return nil
end

return CardSystem