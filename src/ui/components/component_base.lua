-- Classe de base pour tous les composants UI
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(params)
    local self = setmetatable({}, ComponentBase)
    
    -- Position relative (0-1) dans la zone parent
    self.relX = params.relX or 0
    self.relY = params.relY or 0
    
    -- Dimensions relatives (0-1) de la zone parent
    self.relWidth = params.relWidth or 0.2
    self.relHeight = params.relHeight or 0.1
    
    -- Marges (en pixels après mise à l'échelle)
    self.margin = params.margin or {top=0, right=0, bottom=0, left=0}
    
    -- Position absolue calculée (en pixels)
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
    
    -- Visibilité
    self.visible = params.visible ~= false
    
    -- Référence au gestionnaire d'échelle pour les calculs
    self.scaleManager = params.scaleManager
    
    -- Identifiant du composant
    self.id = params.id or "unnamed_component"
    
    return self
end

-- Calcule les positions et dimensions absolues basées sur la position et taille du parent
function ComponentBase:calculateBounds(parentX, parentY, parentWidth, parentHeight)
    -- Calcul des coordonnées absolues basées sur la position relative
    self.x = parentX + (parentWidth * self.relX) + self.margin.left
    self.y = parentY + (parentHeight * self.relY) + self.margin.top
    
    -- Calcul des dimensions absolues basées sur les dimensions relatives
    -- en tenant compte des marges
    self.width = (parentWidth * self.relWidth) - self.margin.left - self.margin.right
    self.height = (parentHeight * self.relHeight) - self.margin.top - self.margin.bottom
end

-- Vérifie si un point (x, y) est dans les limites du composant
function ComponentBase:containsPoint(x, y)
    return self.visible and 
           x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Méthode de dessin à implémenter par les classes dérivées
function ComponentBase:draw()
    -- À surcharger dans les classes dérivées
    -- Par défaut, dessine un rectangle de débogage
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
