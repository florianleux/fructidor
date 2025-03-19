-- Classe de base standardisée pour les composants UI
-- Sert de base pour tous les composants de l'interface utilisateur
-- dans le cadre de l'architecture unifiée KISS

local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(params)
    local self = setmetatable({}, ComponentBase)
    
    -- Modèle associé (peut être nil pour les composants purement visuels)
    self.model = params.model
    
    -- Positionnement et dimensions
    self.x = params.x or 0
    self.y = params.y or 0
    self.width = params.width or 100
    self.height = params.height or 100
    
    -- Visibilité
    self.visible = params.visible ~= false
    
    -- Identifiant et dépendances
    self.id = params.id or "unnamed"
    self.scaleManager = params.scaleManager
    
    -- Couleurs par défaut (peuvent être surchargées)
    self.colors = params.colors or {
        background = {0.9, 0.9, 0.9, 1},
        border = {0.7, 0.7, 0.7, 1},
        text = {0.1, 0.1, 0.1, 1},
        highlight = {0.8, 0.9, 1, 0.5}
    }
    
    return self
end

-- Vérification si un point est dans le composant
function ComponentBase:containsPoint(x, y)
    return self.visible and 
           x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Rendu du composant
function ComponentBase:draw()
    -- Implémentation de base pour le débogage
    if self.visible then
        love.graphics.setColor(self.colors.background)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)
        love.graphics.setColor(self.colors.border)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)
    end
end

-- Mise à jour du composant
function ComponentBase:update(dt)
    -- Les composants spécifiques doivent implémenter cette méthode si nécessaire
end

-- Gestion des événements de la souris
function ComponentBase:mousepressed(x, y, button)
    -- Retourne true si l'événement a été traité
    return false
end

function ComponentBase:mousereleased(x, y, button)
    -- Retourne true si l'événement a été traité
    return false
end

function ComponentBase:mousemoved(x, y, dx, dy)
    -- Retourne true si l'événement a été traité
    return false
end

-- Méthode pour obtenir les limites du composant
function ComponentBase:getBounds()
    return self.x, self.y, self.width, self.height
end

-- Méthode pour redimensionner le composant
function ComponentBase:resize(width, height)
    self.width = width
    self.height = height
end

-- Méthode pour repositionner le composant
function ComponentBase:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Support de la compatibilité avec l'ancien code
ComponentBase.isPointInside = ComponentBase.containsPoint
ComponentBase.getScaledBounds = function(self) return self.x, self.y, self.width, self.height end

return ComponentBase