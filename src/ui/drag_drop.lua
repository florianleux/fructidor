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
local RETURN_ANIMATION_DURATION = 0.3 -- Durée de l'animation de retour en ligne droite

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
    
    -- Animation de retour en ligne droite
    self.returnAnimation = {
        active = false,
        startTime = 0,
        duration = RETURN_ANIMATION_DURATION,
        startX = 0,
        startY = 0,
        targetX = 0,
        targetY = 0,
        progress = 0,
        callback = nil
    }
    
    -- État d'affichage
    self.visible = true
    
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

function DragDrop:startReturnAnimation(startX, startY, targetX, targetY, callback)
    self.returnAnimation.active = true
    self.returnAnimation.startTime = love.timer.getTime()
    self.returnAnimation.duration = RETURN_ANIMATION_DURATION
    self.returnAnimation.startX = startX
    self.returnAnimation.startY = startY
    self.returnAnimation.targetX = targetX
    self.returnAnimation.targetY = targetY
    self.returnAnimation.progress = 0
    self.returnAnimation.callback = callback
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

function DragDrop:updateReturnAnimation()
    if not self.returnAnimation.active then return end
    
    local currentTime = love.timer.getTime()
    local elapsedTime = currentTime - self.returnAnimation.startTime
    
    if elapsedTime >= self.returnAnimation.duration then
        -- Animation terminée
        if self.dragging then
            self.dragging.x = self.returnAnimation.targetX
            self.dragging.y = self.returnAnimation.targetY
        end
        self.returnAnimation.active = false
        self.returnAnimation.progress = 1
        
        -- Appeler le callback si défini
        if self.returnAnimation.callback then
            self.returnAnimation.callback()
        end
    else
        -- Animation en cours
        local progress = elapsedTime / self.returnAnimation.duration
        
        -- Fonction d'easing pour une animation plus fluide (outQuad)
        progress = 1 - (1 - progress) * (1 - progress)
        
        -- Mettre à jour la position seulement si dragging existe encore
        if self.dragging then
            self.dragging.x = self.returnAnimation.startX + 
                             (self.returnAnimation.targetX - self.returnAnimation.startX) * progress
            self.dragging.y = self.returnAnimation.startY + 
                             (self.returnAnimation.targetY - self.returnAnimation.startY) * progress
        end
        
        self.returnAnimation.progress = progress
    end
end

function DragDrop:update(dt)
    -- Mettre à jour les animations si actives
    self:updateAnimation()
    self:updateReturnAnimation()
    
    -- Vérifier si le curseur est sur la position finale de la carte
    if self.returnAnimation.active and self.dragging then
        local mouseX, mouseY = love.mouse.getPosition()
        local distance = math.sqrt((mouseX - self.dragging.x)^2 + (mouseY - self.dragging.y)^2)
        
        -- Si le curseur est proche de la position finale et l'animation est presque terminée,
        -- rendre la carte temporairement invisible pour éviter le scintillement
        if distance < CARD_WIDTH/2 and self.returnAnimation.progress > 0.8 then
            self.visible = false
        else
            self.visible = true
        end
    else
        self.visible = true
    end
end

function DragDrop:startDrag(card, cardIndex, x, y)
    -- Ignorer si une animation est déjà en cours
    if self.animation.active or self.returnAnimation.active then return end
    
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
    
    -- Rendre la carte visible
    self.visible = true
    
    -- Mettre à jour immédiatement la position de la carte
    self:updateDrag(x, y)
end

function DragDrop:updateDrag(x, y)
    if not self.dragging or self.returnAnimation.active then return end
    
    -- La carte suit directement le curseur
    self.dragging.x = x
    self.dragging.y = y
end

function DragDrop:stopDrag(garden, cardSystem)
    if not self.dragging or not self.originalCard then return false end
    
    -- Ne pas permettre de relâcher pendant une animation de retour
    if self.returnAnimation.active then return false end
    
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
    
    -- Si la carte n'a pas été placée, animer son retour à la main en ligne droite
    if not placed then
        -- Réinitialiser l'état du système de cartes
        if cardSystem then
            cardSystem:resetDragging()
        end
        
        -- Mémoriser la position actuelle de la carte
        local startX = self.dragging.x
        local startY = self.dragging.y
        
        -- Position de destination (position originale de la carte dans la main)
        local targetX = self.originalCard.x
        local targetY = self.originalCard.y
        
        -- Démarrer l'animation de retour en ligne droite
        self:startReturnAnimation(startX, startY, targetX, targetY, function()
            -- Après l'animation de retour à la position, démarrer l'animation de retour à la taille normale
            self:startAnimation("out", self.animation.scale, 1.0, function()
                -- Nettoyer après la fin des animations
                self.dragging = nil
                self.originalCard = nil
                self.cardIndex = nil
                self.targetCell = nil
                self.visible = true
            end)
        end)
        
        return false
    else
        -- Si la carte a été placée, nettoyer immédiatement
        self.dragging = nil
        self.originalCard = nil
        self.cardIndex = nil
        self.targetCell = nil
        self.animation.active = false
        self.returnAnimation.active = false
        self.visible = true
        
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
    return self.animation.active or self.returnAnimation.active
end

function DragDrop:draw()
    -- Dessiner la carte en cours de déplacement seulement si elle est visible
    if self.dragging and self.visible then
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