-- Système de Drag & Drop simplifié
local Constants = require('src.utils.game_config')

local DragDrop = {}
DragDrop.__index = DragDrop

-- Constantes simplifiées
local ANIMATION_DURATION = 0.3
local CARD_SCALE_DRAGGING = 0.6

function DragDrop.new(dependencies)
    local self = setmetatable({}, DragDrop)
    self.dragging = nil
    self.originalCard = nil
    self.cardIndex = nil
    
    -- Stocker les dépendances
    self.dependencies = dependencies or {}
    self.scaleManager = self.dependencies.scaleManager
    self.cardSystem = self.dependencies.cardSystem
    -- Note: uiManager sera injecté après sa création (dépendance circulaire)
    
    -- Animation simplifiée
    self.animation = {
        active = false,
        startTime = 0,
        duration = ANIMATION_DURATION,
        startX = 0, startY = 0,
        targetX = 0, targetY = 0,
        scale = CARD_SCALE_DRAGGING
    }
    
    return self
end

function DragDrop:update(dt)
    -- Mettre à jour l'animation si active
    if self.animation.active then
        local currentTime = love.timer.getTime()
        local elapsedTime = currentTime - self.animation.startTime
        local progress = math.min(1, elapsedTime / self.animation.duration)
        
        -- Easing simple: quadratique
        progress = 1 - (1 - progress) * (1 - progress)
        
        if self.dragging then
            self.dragging.x = self.animation.startX + (self.animation.targetX - self.animation.startX) * progress
            self.dragging.y = self.animation.startY + (self.animation.targetY - self.animation.startY) * progress
        end
        
        -- Animation terminée
        if progress >= 1 then
            self:endAnimation()
        end
    end
    
    -- Mettre à jour la position de la carte en déplacement
    if self.dragging and not self.animation.active then
        local mouseX = love.mouse.getX() / (self.scaleManager and self.scaleManager.scale or 1)
        local mouseY = love.mouse.getY() / (self.scaleManager and self.scaleManager.scale or 1)
        
        self.dragging.x = mouseX
        self.dragging.y = mouseY
    end
end

function DragDrop:startDrag(card, cardIndex, cardSystem)
    -- Ignorer si animation en cours
    if self.animation.active then return end
    
    self.originalCard = card
    self.cardIndex = cardIndex
    
    -- Stocker référence au système de cartes si fourni
    if cardSystem then
        self.dependencies.cardSystem = cardSystem
    end
    
    -- Créer une copie pour le drag & drop
    self.dragging = {}
    for k, v in pairs(card) do
        self.dragging[k] = v
    end
    
    -- Position initiale = position de la souris
    local mouseX = love.mouse.getX() / (self.scaleManager and self.scaleManager.scale or 1)
    local mouseY = love.mouse.getY() / (self.scaleManager and self.scaleManager.scale or 1)
    
    self.dragging.x = mouseX
    self.dragging.y = mouseY
end

function DragDrop:stopDrag(garden)
    if not self.dragging or not self.originalCard or self.animation.active then 
        return false 
    end
    
    local placed = false
    
    -- Récupérer le GardenDisplay via l'UIManager injecté
    local uiManager = self.dependencies.uiManager
    local gardenDisplay = uiManager and uiManager.components and uiManager.components.gardenDisplay
    
    -- Trouver la cellule sous la carte
    for y = 1, garden.height do
        for x = 1, garden.width do
            local cellX, cellY, isInside
            
            if gardenDisplay then
                cellX, cellY = gardenDisplay:getCellCoordinates(x, y)
                local cellSize = gardenDisplay.cellSize
                isInside = self.dragging.x >= cellX and 
                           self.dragging.x < cellX + cellSize and
                           self.dragging.y >= cellY and 
                           self.dragging.y < cellY + cellSize
            else
                -- Fallback simple si gardenDisplay n'est pas disponible
                local cellSize = 70
                local gardenX = 100
                local gardenY = 200
                
                cellX = gardenX + (x-1) * cellSize
                cellY = gardenY + (y-1) * cellSize
                isInside = self.dragging.x >= cellX and 
                           self.dragging.x < cellX + cellSize and
                           self.dragging.y >= cellY and 
                           self.dragging.y < cellY + cellSize
            end
            
            if isInside then
                -- Tenter de placer la plante
                if not garden.grid[y][x].plant then
                    if self.cardIndex and self.dependencies.cardSystem then
                        placed = self.dependencies.cardSystem:playCard(self.cardIndex, garden, x, y)
                    end
                end
                
                break
            end
        end
        if placed then break end
    end
    
    -- Si non placée, animer le retour à la main
    if not placed then
        self.animation.active = true
        self.animation.startTime = love.timer.getTime()
        self.animation.startX = self.dragging.x
        self.animation.startY = self.dragging.y
        self.animation.targetX = self.originalCard.x
        self.animation.targetY = self.originalCard.y
        
        return false
    else
        -- Si placée, nettoyer immédiatement
        self:endAnimation()
        return placed
    end
end

-- Méthode pour terminer le drag & drop
function DragDrop:endAnimation()
    self.dragging = nil
    self.originalCard = nil
    self.cardIndex = nil
    self.animation.active = false
end

function DragDrop:isDragging()
    return self.dragging ~= nil
end

function DragDrop:getDraggingCard()
    return self.dragging
end

function DragDrop:getDraggingCardIndex()
    return self.cardIndex
end

function DragDrop:isAnimating()
    return self.animation.active
end

function DragDrop:draw()
    -- Dessiner la carte en cours de déplacement ou d'animation
    if self.dragging then
        local scale = self.animation.scale
        local w = Constants.UI.CARD.WIDTH * scale
        local h = Constants.UI.CARD.HEIGHT * scale
        
        -- Dessiner une ombre
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 
            self.dragging.x - w/2 + 3, 
            self.dragging.y - h/2 + 3, 
            w, h, 5)
        
        -- Dessiner la carte
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 
            self.dragging.x - w/2, 
            self.dragging.y - h/2, 
            w, h, 5)
        
        -- Dessiner le contenu de la carte
        love.graphics.setColor(self.dragging.color or {0.7, 0.7, 0.7})
        love.graphics.rectangle("fill", 
            self.dragging.x - w/2 + 3 * scale, 
            self.dragging.y - h/2 + 3 * scale, 
            w - 6 * scale, 20 * scale)
        
        -- Dessiner le texte
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.dragging.family or "?", 
            self.dragging.x - w/2 + 6 * scale, 
            self.dragging.y - h/2 + 5 * scale, 
            0, 0.8 * scale, 0.8 * scale)
    end
end

return DragDrop