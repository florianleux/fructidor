-- Composant unifié de carte (remplace card_renderer.lua)
-- Suit le modèle d'architecture KISS à deux niveaux
local ComponentBase = require('src.ui.components.component_base')
local GameConfig = require('src.utils.game_config')
local Localization = require('src.utils.localization')

local CardComponent = setmetatable({}, {__index = ComponentBase})
CardComponent.__index = CardComponent

-- Utilisation des constantes centralisées
local CARD_WIDTH = GameConfig.UI.CARD.WIDTH
local CARD_HEIGHT = GameConfig.UI.CARD.HEIGHT
local CARD_CORNER_RADIUS = GameConfig.UI.CARD.CORNER_RADIUS
local CARD_HEADER_HEIGHT = GameConfig.UI.CARD.HEADER_HEIGHT
local TEXT_SCALE = GameConfig.UI.CARD.TEXT_SCALE

function CardComponent.new(params)
    local self = setmetatable(ComponentBase.new(params), CardComponent)
    
    -- Modèle associé (la carte)
    self.model = params.card
    
    -- Alias pour faciliter la transition du code existant
    self.card = self.model
    
    -- Position pour faciliter le rendu
    if params.card then
        self.x = params.card.x or params.x or 0
        self.y = params.card.y or params.y or 0
    end
    
    -- Dimensions standards
    self.width = CARD_WIDTH
    self.height = CARD_HEIGHT
    
    -- Animation et état
    self.isHovered = false
    self.isSelected = false
    self.animationScale = 1.0
    
    -- Callback quand la carte est cliquée
    self.onClick = params.onClick
    
    return self
end

-- Mise à jour de l'animation et la position
function CardComponent:update(dt)
    if self.card then
        -- Mettre à jour la position si la carte a été déplacée
        self.x = self.card.x
        self.y = self.card.y
        
        -- Animation si nécessaire (exemple: entrée/sortie d'une carte)
        -- ...
    end
end

-- Rendu de la carte
function CardComponent:draw()
    if not self.card or not self.visible then return end
    
    -- Calculer les positions ajustées pour la carte
    local cardLeft = self.x - CARD_WIDTH/2
    local cardTop = self.y - CARD_HEIGHT/2
    
    -- Appliquer l'échelle d'animation si nécessaire
    local scale = self.animationScale
    if scale ~= 1.0 then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.scale(scale, scale)
        love.graphics.translate(-self.x, -self.y)
    end
    
    -- Dessiner le fond de la carte
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
    
    -- Bordure (plus épaisse si survolée ou sélectionnée)
    if self.isSelected then
        love.graphics.setColor(0.2, 0.6, 0.8, 1)
        love.graphics.setLineWidth(2)
    elseif self.isHovered then
        love.graphics.setColor(0.4, 0.7, 0.9, 1)
        love.graphics.setLineWidth(1.5)
    else
        love.graphics.setColor(0.4, 0.4, 0.4, 1)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
    love.graphics.setLineWidth(1) -- Restaurer la largeur de ligne par défaut
    
    -- Couleur de fond selon la famille
    if self.card.color then
        love.graphics.setColor(self.card.color[1], self.card.color[2], self.card.color[3], 1)
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
    end
    love.graphics.rectangle("fill", cardLeft + 3, cardTop + 3, CARD_WIDTH - 6, CARD_HEADER_HEIGHT)
    
    -- Obtenir le texte localisé pour la famille
    local familyText
    if Localization and Localization.getText then
        familyText = Localization.getText(self.card.family) or self.card.family
    else
        familyText = self.card.family
    end
    
    -- Nom et info
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(familyText, cardLeft + 6, cardTop + 5, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Info sur le stade
    local stageText = "Graine" -- Par défaut
    if Localization and Localization.getText and GameConfig and GameConfig.GROWTH_STAGE and GameConfig.GROWTH_STAGE.SEED then
        stageText = Localization.getText(GameConfig.GROWTH_STAGE.SEED) or "Graine"
    end
    love.graphics.print(stageText, cardLeft + 6, cardTop + 21, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Besoins pour pousser
    love.graphics.print("☀️ " .. self.card.sunToSprout, cardLeft + 6, cardTop + 36, 0, TEXT_SCALE, TEXT_SCALE)
    love.graphics.print("🌧️ " .. self.card.rainToSprout, cardLeft + 6, cardTop + 51, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Score
    local pointsText = "pts"
    if Localization and Localization.getText then
        pointsText = Localization.getText("ui.points") or "pts"
    end
    love.graphics.print(self.card.baseScore .. " " .. pointsText, cardLeft + 6, cardTop + 66, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Gel
    love.graphics.print("❄️ " .. self.card.frostThreshold, cardLeft + 6, cardTop + 81, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Restaurer l'échelle si on l'a modifiée
    if scale ~= 1.0 then
        love.graphics.pop()
    end
end

-- Gestion des événements de souris
function CardComponent:mousepressed(x, y, button)
    if button == 1 and self:containsPoint(x, y) then
        -- Clic sur la carte
        if self.onClick then
            self.onClick(self.card)
        end
        self.isSelected = true
        return true
    end
    
    return false
end

function CardComponent:mousereleased(x, y, button)
    if button == 1 and self.isSelected then
        self.isSelected = false
        return true
    end
    
    return false
end

function CardComponent:mousemoved(x, y, dx, dy)
    -- Mettre à jour l'état de survol
    local wasHovered = self.isHovered
    self.isHovered = self:containsPoint(x, y)
    
    -- Si l'état de survol a changé, retourner true
    return wasHovered ~= self.isHovered
end

-- Détermine si un point est dans la carte (avec prise en compte de l'échelle)
function CardComponent:containsPoint(x, y)
    if not self.visible then return false end
    
    -- Tenir compte de la taille réelle de la carte avec animation
    local halfWidth = (CARD_WIDTH * self.animationScale) / 2
    local halfHeight = (CARD_HEIGHT * self.animationScale) / 2
    
    return x >= self.x - halfWidth and x <= self.x + halfWidth and
           y >= self.y - halfHeight and y <= self.y + halfHeight
end

-- Méthode utilitaire pour animer la carte
function CardComponent:setAnimationScale(scale)
    self.animationScale = scale
end

-- Méthode utilitaire pour obtenir les dimensions standards d'une carte
function CardComponent:getCardDimensions()
    return CARD_WIDTH, CARD_HEIGHT
end

return CardComponent