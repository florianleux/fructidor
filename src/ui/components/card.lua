-- Composant Carte
local UIComponent = require('src.ui.components.ui_component')

local Card = setmetatable({}, {__index = UIComponent})
Card.__index = Card

-- Création d'une nouvelle carte
-- @param x Position X en pixels (basée sur résolution HD)
-- @param y Position Y en pixels (basée sur résolution HD)
-- @param data Table contenant les données de la carte (famille, points soleil/pluie, etc.)
function Card.new(x, y, data)
    -- Dimensions standard en pixels (pour résolution HD)
    local CARD_WIDTH = 108
    local CARD_HEIGHT = 180
    
    -- Créer le composant de base
    local self = setmetatable(UIComponent.new(x, y, CARD_WIDTH, CARD_HEIGHT), Card)
    
    -- Copier les données de la carte
    self.data = data or {}
    self.family = data.family or "Unknown"
    self.color = data.color or {0.7, 0.7, 0.7, 1.0}
    self.sunToSprout = data.sunToSprout or 0
    self.rainToSprout = data.rainToSprout or 0
    self.sunToFruit = data.sunToFruit or 0
    self.rainToFruit = data.rainToFruit or 0
    self.baseScore = data.baseScore or 0
    self.frostThreshold = data.frostThreshold or 0
    self.stage = data.stage or "Graine"
    
    -- Propriétés visuelles (toutes en pixels HD)
    self.cornerRadius = 5
    self.headerHeight = 27
    self.headerPadding = 3
    self.textPadding = 6
    self.lineHeight = 16
    self.textScale = 0.84
    self.cardState = "normal" -- normal, hover, selected, dragging
    
    return self
end

-- Mise à jour de la carte
function Card:update(dt)
    if not self.visible then
        return
    end
    
    -- Mise à jour de l'état de la carte (hover, etc.)
    local mouseX, mouseY = love.mouse.getPosition()
    if self:contains(mouseX, mouseY) then
        self.cardState = "hover"
    else
        self.cardState = "normal"
    end
end

-- Dessin de la carte
function Card:draw()
    if not self.visible then
        return
    end
    
    -- Adapter les propriétés visuelles à l'échelle
    local cornerRadius = self.cornerRadius * self.scale
    local headerHeight = self.headerHeight * self.scale
    local headerPadding = self.headerPadding * self.scale
    local textPadding = self.textPadding * self.scale
    local lineHeight = self.lineHeight * self.scale
    
    -- Dessiner une ombre
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", 
        self.x + 2 * self.scale, 
        self.y + 2 * self.scale, 
        self.width, self.height, cornerRadius)
    
    -- Dessiner la carte elle-même
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, cornerRadius)
    
    -- Couleur de fond selon la famille
    love.graphics.setColor(unpack(self.color))
    love.graphics.rectangle("fill", 
        self.x + headerPadding, 
        self.y + headerPadding, 
        self.width - (headerPadding * 2), 
        headerHeight)
    
    -- Calculer l'échelle du texte pour les cartes
    local textDisplayScale = self.textScale * self.scale
    
    -- Nom et info
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.family, 
        self.x + textPadding, 
        self.y + textPadding, 
        0, textDisplayScale, textDisplayScale)
    
    love.graphics.print(self.stage, 
        self.x + textPadding, 
        self.y + textPadding + lineHeight, 
        0, textDisplayScale, textDisplayScale)
    
    -- Besoins pour pousser
    love.graphics.print("☀️ " .. self.sunToSprout, 
        self.x + textPadding, 
        self.y + textPadding + lineHeight * 2, 
        0, textDisplayScale, textDisplayScale)
    
    love.graphics.print("🌧️ " .. self.rainToSprout, 
        self.x + textPadding, 
        self.y + textPadding + lineHeight * 3, 
        0, textDisplayScale, textDisplayScale)
    
    -- Score
    love.graphics.print(self.baseScore .. " pts", 
        self.x + textPadding, 
        self.y + textPadding + lineHeight * 4, 
        0, textDisplayScale, textDisplayScale)
    
    -- Gel
    love.graphics.print("❄️ " .. self.frostThreshold, 
        self.x + textPadding, 
        self.y + textPadding + lineHeight * 5, 
        0, textDisplayScale, textDisplayScale)
    
    -- Si la carte est survolée ou sélectionnée, ajouter un effet
    if self.cardState == "hover" then
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius)
    elseif self.cardState == "selected" then
        love.graphics.setColor(0.3, 0.8, 0.3, 0.3)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius)
    end
    
    -- Restaurer la couleur
    love.graphics.setColor(1, 1, 1, 1)
end

-- Gestionnaire d'événements pour la carte
function Card:onEvent(event, x, y, button)
    if not self.visible then
        return false
    end
    
    if event == "mousepressed" and button == 1 and self:contains(x, y) then
        self.cardState = "selected"
        return true
    elseif event == "mousereleased" and button == 1 and self.cardState == "selected" then
        if self:contains(x, y) then
            -- Traitement du clic sur la carte
            self.cardState = "hover"
            return true
        else
            self.cardState = "normal"
        end
    end
    
    return false
end

-- Sélectionner la carte
function Card:select()
    self.cardState = "selected"
end

-- Désélectionner la carte
function Card:deselect()
    self.cardState = "normal"
end

-- Définir le statut de la carte (Graine, Plant, Fructifié)
function Card:setStage(stage)
    self.stage = stage or "Graine"
end

return Card