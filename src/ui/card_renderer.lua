-- Renderer dédié pour les cartes
local Constants = require('src.utils.constants')
local Localization = require('src.utils.localization')

local CardRenderer = {}
CardRenderer.__index = CardRenderer

-- Définition des constantes pour la taille des cartes (180% de la taille originale)
local CARD_WIDTH = 108  -- 60 * 1.8
local CARD_HEIGHT = 180 -- 100 * 1.8
local CARD_CORNER_RADIUS = 5
local CARD_HEADER_HEIGHT = 27 -- 15 * 1.8
local TEXT_SCALE = 1.4
local DEBUG_RENDER = true -- Activer le mode débogage

function CardRenderer.new()
    local self = setmetatable({}, CardRenderer)
    print("CardRenderer initialisé")
    return self
end

-- Retourne les dimensions standard d'une carte
function CardRenderer:getCardDimensions()
    return CARD_WIDTH, CARD_HEIGHT
end

-- Méthode pour dessiner une carte à une position donnée
function CardRenderer:draw(card, xPos, yPos)
    if DEBUG_RENDER then
        print("CardRenderer:draw appelé pour " .. card.family .. " à " .. xPos .. "," .. yPos)
    end
    
    -- Calculer les positions ajustées pour la carte agrandie
    local cardLeft = xPos - CARD_WIDTH/2
    local cardTop = yPos - CARD_HEIGHT/2
    
    -- Dessiner le fond de la carte
    love.graphics.push("all") -- Sauvegarder l'état graphique actuel
    
    -- Dessiner une bordure plus visible en mode debug
    if DEBUG_RENDER then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("line", cardLeft-2, cardTop-2, CARD_WIDTH+4, CARD_HEIGHT+4, CARD_CORNER_RADIUS+2, 3)
    end
    
    -- Fond de carte
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("line", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
    
    -- Couleur de fond selon la famille
    if card.color then
        love.graphics.setColor(card.color[1], card.color[2], card.color[3], 1)
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
    end
    love.graphics.rectangle("fill", cardLeft + 5, cardTop + 5, CARD_WIDTH - 10, CARD_HEADER_HEIGHT)
    
    -- Obtenir le texte localisé pour la famille
    local familyText
    if Localization and Localization.getText then
        familyText = Localization.getText(card.family) or card.family
    else
        familyText = card.family
    end
    
    -- Nom et info
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(familyText, cardLeft + 10, cardTop + 9, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Info sur le stade
    local stageText = "Graine" -- Par défaut
    if Localization and Localization.getText and Constants and Constants.GROWTH_STAGE and Constants.GROWTH_STAGE.SEED then
        stageText = Localization.getText(Constants.GROWTH_STAGE.SEED) or "Graine"
    end
    love.graphics.print(stageText, cardLeft + 10, cardTop + 35, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Besoins pour pousser
    love.graphics.print("☀️ " .. card.sunToSprout, cardLeft + 10, cardTop + 60, 0, TEXT_SCALE, TEXT_SCALE)
    love.graphics.print("🌧️ " .. card.rainToSprout, cardLeft + 10, cardTop + 85, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Score
    local pointsText = "pts"
    if Localization and Localization.getText then
        pointsText = Localization.getText("ui.points") or "pts"
    end
    love.graphics.print(card.baseScore .. " " .. pointsText, cardLeft + 10, cardTop + 110, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Gel
    love.graphics.print("❄️ " .. card.frostThreshold, cardLeft + 10, cardTop + 135, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Restaurer l'état graphique
    love.graphics.pop()
    
    if DEBUG_RENDER then
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.circle("fill", xPos, yPos, 5)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return CardRenderer