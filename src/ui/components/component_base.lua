-- Classe de base pour tous les composants UI
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(params)
    local self = setmetatable({}, ComponentBase)
    
    -- Référence au gestionnaire d'échelle pour les calculs
    self.scaleManager = params.scaleManager
    
    -- Position absolue en pixels (basée sur dimensions HD de référence 1920x1080)
    self.pixelX = params.pixelX or 0
    self.pixelY = params.pixelY or 0
    
    -- Dimensions absolues en pixels (basées sur dimensions HD de référence 1920x1080)
    self.pixelWidth = params.pixelWidth or 384  -- 20% de 1920 par défaut
    self.pixelHeight = params.pixelHeight or 108  -- 10% de 1080 par défaut
    
    -- Conversion des anciennes valeurs relatives si fournies pour compatibilité
    if params.relX or params.relY or params.relWidth or params.relHeight then
        -- Conversion des positions et dimensions relatives en pixels
        self.pixelX = params.relX and math.floor(params.relX * self.scaleManager.referenceWidth) or self.pixelX
        self.pixelY = params.relY and math.floor(params.relY * self.scaleManager.referenceHeight) or self.pixelY
        self.pixelWidth = params.relWidth and math.floor(params.relWidth * self.scaleManager.referenceWidth) or self.pixelWidth
        self.pixelHeight = params.relHeight and math.floor(params.relHeight * self.scaleManager.referenceHeight) or self.pixelHeight
    end
    
    -- Marges (en pixels)
    self.margin = params.margin or {top=0, right=0, bottom=0, left=0}
    
    -- Position et dimensions finales après calcul
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
    
    -- Visibilité
    self.visible = params.visible ~= false
    
    -- Identifiant du composant
    self.id = params.id or "unnamed_component"
    
    return self
end

-- Calcule les positions et dimensions absolues basées sur la position et taille du parent
function ComponentBase:calculateBounds(parentX, parentY, parentWidth, parentHeight)
    -- Pourcentage du parent utilisé pour positionner le composant
    local parentRatioX = parentWidth / self.scaleManager.referenceWidth
    local parentRatioY = parentHeight / self.scaleManager.referenceHeight
    
    -- Calcul des coordonnées absolues basées sur les positions en pixels et les marges
    self.x = parentX + (self.pixelX * parentRatioX) + self.margin.left
    self.y = parentY + (self.pixelY * parentRatioY) + self.margin.top
    
    -- Calcul des dimensions absolues basées sur les dimensions en pixels
    -- en tenant compte des marges
    self.width = (self.pixelWidth * parentRatioX) - self.margin.left - self.margin.right
    self.height = (self.pixelHeight * parentRatioY) - self.margin.top - self.margin.bottom
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
