-- Classe de base simplifiée pour les composants UI
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(params)
    local self = setmetatable({}, ComponentBase)
    
    -- Positionnement direct
    self.x = params.x or 0
    self.y = params.y or 0
    self.width = params.width or 100
    self.height = params.height or 100
    
    -- Visibilité
    self.visible = params.visible ~= false
    
    -- Identifiant et dépendances
    self.id = params.id or "unnamed"
    self.scaleManager = params.scaleManager
    
    return self
end

-- Vérification si un point est dans le composant
function ComponentBase:containsPoint(x, y)
    return self.visible and 
           x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Méthodes d'événements
function ComponentBase:draw()
    -- Version debug simple
    if self.visible then
        love.graphics.setColor(0.8, 0.8, 0.8, 0.3)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
end

-- L'API a été simplifiée pour réduire les méthodes redondantes
function ComponentBase:update(dt) end
function ComponentBase:mousepressed(x, y, button) return false end
function ComponentBase:mousereleased(x, y, button) return false end 
function ComponentBase:mousemoved(x, y, dx, dy) return false end

-- Support de la compatibilité
ComponentBase.isPointInside = ComponentBase.containsPoint
ComponentBase.getBounds = function(self) return self.x, self.y, self.width, self.height end
ComponentBase.getScaledBounds = function(self) return self.x, self.y, self.width, self.height end

return ComponentBase