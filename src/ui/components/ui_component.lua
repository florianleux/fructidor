-- Classe de base pour tous les composants d'interface utilisateur
local ScaleManager = require('src.utils.scale_manager')

local UIComponent = {}
UIComponent.__index = UIComponent

-- Créer un nouveau composant UI
-- @param x Position X en pixels (basée sur résolution HD)
-- @param y Position Y en pixels (basée sur résolution HD)
-- @param width Largeur en pixels (basée sur résolution HD)
-- @param height Hauteur en pixels (basée sur résolution HD)
function UIComponent.new(x, y, width, height)
    local self = setmetatable({}, UIComponent)
    
    -- Dimensions en pixels basées sur la référence HD
    self.pixelX = x or 0
    self.pixelY = y or 0
    self.pixelWidth = width or 0
    self.pixelHeight = height or 0
    
    -- Propriétés calculées après mise à l'échelle (mises à jour dans update)
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
    
    -- Propriétés visuelles
    self.visible = true
    self.alpha = 1.0
    
    -- Mettre à jour les dimensions mises à l'échelle immédiatement
    self:updateScale()
    
    return self
end

-- Mettre à jour les dimensions mises à l'échelle
function UIComponent:updateScale()
    -- Vérifier que le ScaleManager est initialisé
    if not ScaleManager.initialized then
        self.x = self.pixelX
        self.y = self.pixelY
        self.width = self.pixelWidth
        self.height = self.pixelHeight
        return
    end
    
    -- Calculer les valeurs mises à l'échelle
    self.x = self.pixelX * ScaleManager.scale
    self.y = self.pixelY * ScaleManager.scale
    self.width = self.pixelWidth * ScaleManager.scale
    self.height = self.pixelHeight * ScaleManager.scale
end

-- Définir la position
function UIComponent:setPosition(x, y)
    self.pixelX = x
    self.pixelY = y
    self:updateScale()
end

-- Définir les dimensions
function UIComponent:setDimensions(width, height)
    self.pixelWidth = width
    self.pixelHeight = height
    self:updateScale()
end

-- Vérifier si un point est à l'intérieur du composant
function UIComponent:contains(x, y)
    if not self.visible then
        return false
    end
    
    -- Vérifier que le point est dans les limites du composant
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Méthode de mise à jour à surcharger par les composants enfants
function UIComponent:update(dt)
    -- À implémenter dans les sous-classes
end

-- Méthode de dessin à surcharger par les composants enfants
function UIComponent:draw()
    -- À implémenter dans les sous-classes
end

-- Gestionnaire d'événements à surcharger par les composants enfants
function UIComponent:onEvent(event, x, y, ...)
    -- À implémenter dans les sous-classes
    return false -- Indique si l'événement a été traité
end

return UIComponent