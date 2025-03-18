-- Classe de base simplifiée pour tous les composants UI
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(params)
    local self = setmetatable({}, ComponentBase)
    
    -- Positions directes pour le prototype alpha (pas de calculs complexes)
    self.x = params.x or 0
    self.y = params.y or 0
    self.width = params.width or 384  -- Défaut hérité
    self.height = params.height or 108  -- Défaut hérité
    
    -- Visibilité
    self.visible = params.visible ~= false
    
    -- Identifiant du composant
    self.id = params.id or "unnamed_component"
    
    -- Enregistrer la référence au gestionnaire d'échelle pour compatibilité
    self.scaleManager = params.scaleManager
    
    return self
end

-- Retourne les dimensions et positions actuelles (version simplifiée)
function ComponentBase:getBounds()
    return self.x, self.y, self.width, self.height
end

-- Fonction de compatibilité avec l'ancien système
function ComponentBase:getScaledBounds()
    return self:getBounds()
end

-- Vérifie si un point (x, y) est dans les limites du composant
function ComponentBase:containsPoint(x, y)
    return self.visible and 
           x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Alias de containsPoint pour maintenir la compatibilité
function ComponentBase:isPointInside(x, y)
    return self:containsPoint(x, y)
end

-- Méthode de dessin à implémenter par les classes dérivées
function ComponentBase:draw()
    -- Implémentation par défaut pour le débogage
    if self.visible then
        love.graphics.setColor(0.8, 0.8, 0.8, 0.3)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.print(self.id, self.x + 5, self.y + 5)
    end
end

-- Méthode de mise à jour à implémenter par les classes dérivées
function ComponentBase:update(dt)
    -- À surcharger dans les classes dérivées
end

-- Gestion des événements souris
function ComponentBase:mousepressed(x, y, button)
    -- À surcharger dans les classes dérivées
    return false  -- Indique si l'événement a été consommé
end

function ComponentBase:mousereleased(x, y, button)
    -- À surcharger dans les classes dérivées
    return false  -- Indique si l'événement a été consommé
end

function ComponentBase:mousemoved(x, y, dx, dy)
    -- À surcharger dans les classes dérivées
    return false  -- Indique si l'événement a été consommé
end

return ComponentBase