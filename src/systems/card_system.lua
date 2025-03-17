-- Système de gestion des cartes
local Plant = require('src.entities.plant')
local Constants = require('src.utils.constants')
local DependencyContainer = require('src.utils.dependency_container')

local CardSystem = {}
CardSystem.__index = CardSystem

-- Définition des constantes pour la taille des cartes
local CARD_WIDTH = 108
local CARD_HEIGHT = 180

-- Le constructeur prend désormais des dépendances optionnelles
function CardSystem.new(dependencies)
    local self = setmetatable({}, CardSystem)
    self.deck = {}
    self.hand = {}
    self.discardPile = {}
    self.draggingCardIndex = nil -- Indice de la carte en cours de déplacement
    self.cardInAnimation = nil -- Indice de la carte en cours d'animation
    
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
            type = Constants.CARD_TYPE.PLANT,
            family = Constants.PLANT_FAMILY.BRASSIKA,
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
            type = Constants.CARD_TYPE.PLANT,
            family = Constants.PLANT_FAMILY.SOLANA,
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
    
    if card.type == Constants.CARD_TYPE.PLANT then
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
            
            -- Réinitialiser aussi l'indice de la carte en animation si nécessaire
            if self.cardInAnimation == cardIndex then
                self.cardInAnimation = nil
            elseif self.cardInAnimation and self.cardInAnimation > cardIndex then
                -- Ajuster l'indice si une carte avant celle en animation est supprimée
                self.cardInAnimation = self.cardInAnimation - 1
            end
            
            return true
        end
    end
    
    return false
end

-- Fonction pour dessiner la main du joueur en utilisant le renderer
function CardSystem:drawHand()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local handY
    
    -- Adapter les coordonnées en fonction de l'échelle
    if self.scaleManager then
        -- Pour la version scalée, nous utilisons une position fixe qui sera
        -- adaptée automatiquement par le système de scaling
        screenWidth = self.scaleManager.referenceWidth
        screenHeight = self.scaleManager.referenceHeight
        handY = screenHeight - 100
    else
        handY = screenHeight - 100
    end
    
    -- Récupérer le renderer de cartes via l'injecteur de dépendances
    local cardRenderer = DependencyContainer.resolve("CardRenderer")
    
    -- Calculer la position des cartes en arc
    for i, card in ipairs(self.hand) do
        -- Ignorer la carte en cours de déplacement ou d'animation
        if i ~= self.draggingCardIndex and i ~= self.cardInAnimation then
            local angle = (i - (#self.hand + 1) / 2) * 0.1
            local x = screenWidth / 2 + angle * 270
            local y = handY + math.abs(angle) * 70
            
            -- Stocker la position pour le drag & drop
            card.x = x
            card.y = y
            
            -- Dessiner la carte en utilisant le renderer
            cardRenderer:draw(card, x, y)
        end
    end
end

-- Fonction pour savoir si un point est sur une carte
function CardSystem:getCardAt(x, y)
    local cardWidth, cardHeight = CARD_WIDTH, CARD_HEIGHT
    
    for i = #self.hand, 1, -1 do -- Regarder de haut en bas
        -- Ignorer les cartes en animation
        if i ~= self.cardInAnimation then
            local card = self.hand[i]
            if x >= card.x - cardWidth/2 and x <= card.x + cardWidth/2 and
               y >= card.y - cardHeight/2 and y <= card.y + cardHeight/2 then
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

-- Définir la carte en cours d'animation
function CardSystem:setCardInAnimation(index)
    self.cardInAnimation = index
    -- Désactiver le dragging si c'est la même carte
    if self.draggingCardIndex == index then
        self.draggingCardIndex = nil
    end
end

-- Réinitialiser la carte en animation
function CardSystem:clearCardInAnimation(index)
    -- Ne réinitialiser que si l'index est le même que celui qui est actuellement animé
    if index == nil or self.cardInAnimation == index then
        self.cardInAnimation = nil
    end
end

-- Réinitialiser l'état de déplacement
function CardSystem:resetDragging()
    self.draggingCardIndex = nil
end

return CardSystem