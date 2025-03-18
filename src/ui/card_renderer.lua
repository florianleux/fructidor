-- Renderer dédié pour les cartes
local Constants = require('src.utils.constants')
local Localization = require('src.utils.localization')

local CardRenderer = {}
CardRenderer.__index = CardRenderer

-- Utilisation des constantes centralisées
local CARD_WIDTH = Constants.UI.CARD.WIDTH
local CARD_HEIGHT = Constants.UI.CARD.HEIGHT
local CARD_CORNER_RADIUS = Constants.UI.CARD.CORNER_RADIUS
local CARD_HEADER_HEIGHT = Constants.UI.CARD.HEADER_HEIGHT
local TEXT_SCALE = Constants.UI.CARD.TEXT_SCALE

function CardRenderer.new()
    local self = setmetatable({}, CardRenderer)
    return self
end

-- Retourne les dimensions standard d'une carte
function CardRenderer:getCardDimensions()
    return CARD_WIDTH, CARD_HEIGHT
end

-- Méthode pour dessiner une carte à une position donnée
function CardRenderer:draw(card, xPos, yPos)
    -- Calculer les positions ajustées pour la carte agrandie
    local cardLeft = xPos - CARD_WIDTH/2
    local cardTop = yPos - CARD_HEIGHT/2
    
    -- Dessiner le fond de la carte
    love.graphics.push("all") -- Sauvegarder l'état graphique actuel
    
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
    love.graphics.rectangle("fill", cardLeft + 3, cardTop + 3, CARD_WIDTH - 6, CARD_HEADER_HEIGHT)
    
    -- Obtenir le texte localisé pour la famille
    local familyText
    if Localization and Localization.getText then
        familyText = Localization.getText(card.family) or card.family
    else
        familyText = card.family
    end
    
    -- Nom et info
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(familyText, cardLeft + 6, cardTop + 5, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Info sur le stade
    local stageText = "Graine" -- Par défaut
    if Localization and Localization.getText and Constants and Constants.GROWTH_STAGE and Constants.GROWTH_STAGE.SEED then
        stageText = Localization.getText(Constants.GROWTH_STAGE.SEED) or "Graine"
    end
    love.graphics.print(stageText, cardLeft + 6, cardTop + 21, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Besoins pour pousser
    love.graphics.print("☀️ " .. card.sunToSprout, cardLeft + 6, cardTop + 36, 0, TEXT_SCALE, TEXT_SCALE)
    love.graphics.print("🌧️ " .. card.rainToSprout, cardLeft + 6, cardTop + 51, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Score
    local pointsText = "pts"
    if Localization and Localization.getText then
        pointsText = Localization.getText("ui.points") or "pts"
    end
    love.graphics.print(card.baseScore .. " " .. pointsText, cardLeft + 6, cardTop + 66, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Gel
    love.graphics.print("❄️ " .. card.frostThreshold, cardLeft + 6, cardTop + 81, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Restaurer l'état graphique
    love.graphics.pop()
end

return CardRenderer