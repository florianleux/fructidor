-- Système de Drag & Drop

local DragDrop = {}
DragDrop.__index = DragDrop

-- Définition des constantes pour la taille des cartes
local CARD_WIDTH = 108  -- Taille de base des cartes (60 * 1.8)
local CARD_HEIGHT = 180 -- (100 * 1.8)
local CARD_CORNER_RADIUS = 5
local CARD_HEADER_HEIGHT = 27 -- (15 * 1.8)
local TEXT_PADDING_X = 45
local TEXT_LINE_HEIGHT = 18

-- Constantes d'animation
local ANIMATION_DURATION = 0.3 -- Durée de l'animation en secondes
local CARD_SCALE_WHEN_DRAGGED = 0.6 -- Taille réduite à 60% (réduction de 40%)

function DragDrop.new()
    local self = setmetatable({}, DragDrop)
    self.dragging = nil -- carte en cours de déplacement
    self.originalCard = nil -- sauvegarde des informations de la carte
    self.cardIndex = nil -- indice de la carte dans la main
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.targetCell = nil -- cellule cible surbrillance
    
    -- État de l'animation
    self.animation = {
        active = false,
        direction = nil, -- "in" pour réduire, "out" pour agrandir
        scale = 1.0,
        startTime = 0,
        duration = ANIMATION_DURATION,
        startScale = 1.0,
        targetScale = 1.0,
        callback = nil
    }
    
    return self
end

function DragDrop:startAnimation(direction, startScale, targetScale, callback)
    self.animation.active = true
    self.animation.direction = direction
    self.animation.startTime = love.timer.getTime()
    self.animation.duration = ANIMATION_DURATION
    self.animation.startScale = startScale
    self.animation.targetScale = targetScale
    self.animation.scale = startScale
    self.animation.callback = callback
end

function DragDrop:updateAnimation()
    if not self.animation.active then return end
    
    local currentTime = love.timer.getTime()
    local elapsedTime = currentTime - self.animation.startTime
    
    if elapsedTime >= self.animation.duration then
        -- Animation terminée
        self.animation.scale = self.animation.targetScale
        self.animation.active = false
        
        -- Appeler le callback si défini
        if self.animation.callback then
            self.animation.callback()
        end
    else
        -- Animation en cours
        local progress = elapsedTime / self.animation.duration
        
        -- Fonction d'easing pour une animation plus fluide (outQuad)
        progress = 1 - (1 - progress) * (1 - progress)
        
        -- Mettre à jour l'échelle
        self.animation.scale = self.animation.startScale + 
                             (self.animation.targetScale - self.animation.startScale) * progress
    end
end

function DragDrop:update(dt)
    -- Mettre à jour l'animation si active
    self:updateAnimation()
end

function DragDrop:startDrag(card, cardIndex, x, y)
    -- Ignorer si une animation est déjà en cours
    if self.animation.active then return end
    
    -- Sauvegarder la carte originale et son indice
    self.originalCard = card
    self.cardIndex = cardIndex
    
    -- Créer une copie pour le drag & drop
    self.dragging = {}
    for k, v in pairs(card) do
        self.dragging[k] = v
    end
    
    -- Calcul des offsets pour centrer la carte sous le curseur
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    
    -- Démarrer l'animation de réduction progressive
    self:startAnimation("in", 1.0, CARD_SCALE_WHEN_DRAGGED)
    
    -- Mettre à jour immédiatement la position de la carte
    self:updateDrag(x, y)
end

function DragDrop:updateDrag(x, y)
    if not self.dragging then return end
    
    -- La carte suit directement le curseur
    self.dragging.x = x
    self.dragging.y = y
end

function DragDrop:stopDrag(garden, cardSystem)
    if not self.dragging or not self.originalCard then return false end
    
    local card = self.originalCard -- Utiliser la carte originale pour les références
    local placed = false
    
    -- Trouver la cellule sous la carte
    for y = 1, garden.height do
        for x = 1, garden.width do
            local posX = 50 + (x-1) * 70
            local posY = 180 + (y-1) * 70
            
            -- Utiliser le centre de la carte pour la détection
            local cardCenterX = self.dragging.x
            local cardCenterY = self.dragging.y
            
            if cardCenterX >= posX and cardCenterX < posX + 70 and
               cardCenterY >= posY and cardCenterY < posY + 70 then
                
                -- Tenter de placer la plante
                if not garden.grid[y][x].plant then
                    if self.cardIndex then
                        placed = cardSystem:playCard(self.cardIndex, garden, x, y)
                    end
                end
                
                break
            end
        end
        if placed then break end
    end
    
    -- Si la carte n'a pas été placée, animer son retour à la taille normale
    if not placed then
        -- Réinitialiser l'état du système de cartes
        if cardSystem then
            cardSystem:resetDragging()
        end
        
        -- Démarrer l'animation de retour à la taille normale
        self:startAnimation("out", self.animation.scale, 1.0, function()
            -- Nettoyer après la fin de l'animation
            self.dragging = nil
            self.originalCard = nil
            self.cardIndex = nil
            self.targetCell = nil
        end)
        
        return false
    else
        -- Si la carte a été placée, nettoyer immédiatement
        self.dragging = nil
        self.originalCard = nil
        self.cardIndex = nil
        self.targetCell = nil
        self.animation.active = false
        
        return placed
    end
end

function DragDrop:updateHighlight(garden, x, y)
    -- Réinitialiser les surbrillances
    for cy = 1, garden.height do
        for cx = 1, garden.width do
            local cell = {
                x = 50 + (cx-1) * 70,
                y = 180 + (cy-1) * 70,
                width = 70,
                height = 70
            }
            
            local highlight = x >= cell.x and x < cell.x + cell.width and
                             y >= cell.y and y < cell.y + cell.height and
                             not garden.grid[cy][cx].plant and
                             self.dragging ~= nil
            
            if highlight then
                self.targetCell = {x = cx, y = cy}
                love.graphics.setColor(0.8, 0.9, 0.7, 0.6)
                love.graphics.rectangle("fill", cell.x, cell.y, cell.width, cell.height)
                love.graphics.setColor(0.4, 0.8, 0.4)
                love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height, 3)
            end
        end
    end
end

function DragDrop:isAnimating()
    return self.animation.active
end

function DragDrop:draw()
    -- Dessiner la carte en cours de déplacement
    if self.dragging then
        local card = self.dragging
        
        -- Appliquer l'échelle actuelle aux dimensions de la carte
        local scaledWidth = CARD_WIDTH * self.animation.scale
        local scaledHeight = CARD_HEIGHT * self.animation.scale
        local scaledHeaderHeight = CARD_HEADER_HEIGHT * self.animation.scale
        
        -- Calculer les positions ajustées pour la carte
        local cardLeft = card.x - scaledWidth/2
        local cardTop = card.y - scaledHeight/2
        
        -- Dessiner une ombre
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 
            cardLeft + 4 * self.animation.scale, 
            cardTop + 4 * self.animation.scale, 
            scaledWidth, scaledHeight, CARD_CORNER_RADIUS)
        
        -- Dessiner la carte elle-même
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", cardLeft, cardTop, scaledWidth, scaledHeight, CARD_CORNER_RADIUS)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("line", cardLeft, cardTop, scaledWidth, scaledHeight, CARD_CORNER_RADIUS)
        
        -- Couleur de fond selon la famille
        if card.color then
            love.graphics.setColor(card.color)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
        end
        love.graphics.rectangle("fill", cardLeft + 5 * self.animation.scale, cardTop + 5 * self.animation.scale, 
                               scaledWidth - 10 * self.animation.scale, scaledHeaderHeight)
        
        -- Calculer l'échelle du texte pour les cartes redimensionnées
        local textScale = 1.4 * self.animation.scale
        
        -- Nom et info
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(card.family, cardLeft + 10 * self.animation.scale, cardTop + 9 * self.animation.scale, 0, textScale, textScale)
        love.graphics.print("Graine", cardLeft + 10 * self.animation.scale, cardTop + 35 * self.animation.scale, 0, textScale, textScale)
        
        -- Besoins pour pousser
        love.graphics.print("☀️ " .. card.sunToSprout, cardLeft + 10 * self.animation.scale, cardTop + 60 * self.animation.scale, 0, textScale, textScale)
        love.graphics.print("🌧️ " .. card.rainToSprout, cardLeft + 10 * self.animation.scale, cardTop + 85 * self.animation.scale, 0, textScale, textScale)
        
        -- Score
        love.graphics.print(card.baseScore .. " pts", cardLeft + 10 * self.animation.scale, cardTop + 110 * self.animation.scale, 0, textScale, textScale)
        
        -- Gel
        love.graphics.print("❄️ " .. card.frostThreshold, cardLeft + 10 * self.animation.scale, cardTop + 135 * self.animation.scale, 0, textScale, textScale)
    end
end

return DragDrop