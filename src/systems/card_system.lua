-- Système de gestion des cartes
local Plant = require('src.entities.plant')

local CardSystem = {}
CardSystem.__index = CardSystem

-- Définition des constantes pour la taille des cartes (180% de la taille originale)
local CARD_WIDTH = 108  -- 60 * 1.8
local CARD_HEIGHT = 180 -- 100 * 1.8
local CARD_CORNER_RADIUS = 5
local CARD_HEADER_HEIGHT = 27 -- 15 * 1.8
local TEXT_PADDING_X = 45 -- 25 * 1.8 
local TEXT_LINE_HEIGHT = 18 -- Ajusté pour les cartes plus grandes

function CardSystem.new()
    local self = setmetatable({}, CardSystem)
    self.deck = {}
    self.hand = {}
    self.discardPile = {}
    self.draggingCardIndex = nil -- Indice de la carte en cours de déplacement
    self.cardInReturnAnimation = nil -- Indice de la carte en cours d'animation de retour
    
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
            type = "plant",
            family = "Solana",
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
    
    if card.type == "plant" then
        local plant = Plant.new(card.family, card.color)
        if garden:placePlant(plant, x, y) then
            table.remove(self.hand, cardIndex)
            table.insert(self.discardPile, card)
            
            -- Réinitialiser l'indice de la carte en drag si c'était celle-là
            if self.draggingCardIndex == cardIndex then
                self.draggingCardIndex = nil
            elseif self.draggingCardIndex and self.draggingCardIndex > cardIndex then
                -- Ajuster l'indice si une carte avant celle en déplacement est supprimée
                self.draggingCardIndex = self.draggingCardIndex - 1
            end
            
            -- Réinitialiser aussi l'indice de la carte en animation de retour si nécessaire
            if self.cardInReturnAnimation == cardIndex then
                self.cardInReturnAnimation = nil
            elseif self.cardInReturnAnimation and self.cardInReturnAnimation > cardIndex then
                -- Ajuster l'indice si une carte avant celle en animation est supprimée
                self.cardInReturnAnimation = self.cardInReturnAnimation - 1
            end
            
            return true
        end
    end
    
    return false
end

-- Fonction pour AFFICHER une carte (renommer pour éviter conflit)
function CardSystem:renderCard(card, xPos, yPos)
    -- Calculer les positions ajustées pour la carte agrandie
    local cardLeft = xPos - CARD_WIDTH/2
    local cardTop = yPos - CARD_HEIGHT/2
    
    -- Dessiner le fond de la carte
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("line", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
    
    -- Couleur de fond selon la famille
    if card.color then
        love.graphics.setColor(card.color)
    else
        love.graphics.setColor(0.7, 0.7, 0.7)
    end
    love.graphics.rectangle("fill", cardLeft + 5, cardTop + 5, CARD_WIDTH - 10, CARD_HEADER_HEIGHT)
    
    -- Échelle du texte pour les cartes plus grandes
    local textScale = 1.4
    
    -- Nom et info
    love.graphics.setColor(0, 0, 0)
    -- Pour le texte à l'échelle, on peut utiliser love.graphics.scale, ou alternativement ajuster les positions
    love.graphics.print(card.family, cardLeft + 10, cardTop + 9, 0, textScale, textScale)
    love.graphics.print("Graine", cardLeft + 10, cardTop + 35, 0, textScale, textScale)
    
    -- Besoins pour pousser
    love.graphics.print("☀️ " .. card.sunToSprout, cardLeft + 10, cardTop + 60, 0, textScale, textScale)
    love.graphics.print("🌧️ " .. card.rainToSprout, cardLeft + 10, cardTop + 85, 0, textScale, textScale)
    
    -- Score
    love.graphics.print(card.baseScore .. " pts", cardLeft + 10, cardTop + 110, 0, textScale, textScale)
    
    -- Gel
    love.graphics.print("❄️ " .. card.frostThreshold, cardLeft + 10, cardTop + 135, 0, textScale, textScale)
end

-- Fonction pour dessiner la main du joueur
function CardSystem:drawHand()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local handY = screenHeight - 100 -- Ajusté pour les cartes plus grandes
    
    -- Calculer la position des cartes en arc
    for i, card in ipairs(self.hand) do
        -- Ignorer la carte en cours de déplacement ou en animation de retour
        if i ~= self.draggingCardIndex and i ~= self.cardInReturnAnimation then
            local angle = (i - (#self.hand + 1) / 2) * 0.1
            local x = screenWidth / 2 + angle * 270 -- Ajusté pour les cartes plus grandes
            local y = handY + math.abs(angle) * 70  -- Ajusté pour les cartes plus grandes
            
            -- Stocker la position pour le drag & drop
            card.x = x
            card.y = y
            
            -- Dessiner la carte
            self:renderCard(card, x, y)
        end
    end
end

-- Fonction pour savoir si un point est sur une carte
function CardSystem:getCardAt(x, y)
    for i = #self.hand, 1, -1 do -- Regarder de haut en bas
        -- Ignorer les cartes en animation de retour
        if i ~= self.cardInReturnAnimation then
            local card = self.hand[i]
            if x >= card.x - CARD_WIDTH/2 and x <= card.x + CARD_WIDTH/2 and
               y >= card.y - CARD_HEIGHT/2 and y <= card.y + CARD_HEIGHT/2 then
                return card, i
            end
        end
    end
    return nil
end

-- Définir la carte en cours de déplacement
function CardSystem:setDraggingCard(index)
    self.draggingCardIndex = index
end

-- Définir la carte en cours d'animation de retour
function CardSystem:setCardInReturnAnimation(index)
    self.cardInReturnAnimation = index
end

-- Réinitialiser la carte en animation de retour
function CardSystem:clearCardInReturnAnimation()
    self.cardInReturnAnimation = nil
end

-- Réinitialiser l'état de déplacement
function CardSystem:resetDragging()
    self.draggingCardIndex = nil
end

return CardSystem