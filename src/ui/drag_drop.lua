-- Système de Drag & Drop
local Timer = require('lib.timer')

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
local DRAG_ANIMATION_METHOD = "outQuad" -- Méthode d'interpolation pour l'animation

function DragDrop.new()
    local self = setmetatable({}, DragDrop)
    self.dragging = nil -- carte en cours de déplacement
    self.originalCard = nil -- sauvegarde des informations de la carte
    self.cardIndex = nil -- indice de la carte dans la main
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.targetCell = nil -- cellule cible surbrillance
    
    -- Ajout d'un timer pour les animations
    self.timer = Timer.new()
    
    -- État de l'animation
    self.animating = false
    self.animation = {
        scale = 1.0, -- Échelle actuelle (1.0 = taille normale)
        direction = nil, -- "in" pour réduire, "out" pour agrandir
        complete = true -- L'animation est-elle terminée
    }
    
    return self
end

function DragDrop:update(dt)
    -- Mettre à jour le timer d'animation
    if self.timer then
        self.timer:update(dt)
    end
end

function DragDrop:startDrag(card, cardIndex, x, y)
    -- Ignorer si une animation est déjà en cours
    if self.animating then return end
    
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
    self.animating = true
    self.animation.direction = "in"
    self.animation.scale = 1.0
    self.animation.complete = false
    
    -- Animer la réduction de la carte (progressivement jusqu'à 60% de sa taille)
    self.timer:tween(
        ANIMATION_DURATION, 
        self.animation, 
        { scale = CARD_SCALE_WHEN_DRAGGED }, 
        DRAG_ANIMATION_METHOD,
        function() 
            self.animating = false
            self.animation.complete = true
        end
    )
    
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
        
        -- Déclencher l'animation de restauration de taille
        self.animating = true
        self.animation.direction = "out"
        self.animation.complete = false
        
        -- Animer le retour à la taille normale
        self.timer:tween(
            ANIMATION_DURATION, 
            self.animation, 
            { scale = 1.0 }, 
            DRAG_ANIMATION_METHOD,
            function()
                self.animating = false
                self.animation.complete = true
                
                -- Nettoyer la référence après l'animation terminée
                self.dragging = nil
                self.originalCard = nil
                self.cardIndex = nil
                self.targetCell = nil
            end
        )
        
        -- Ne pas effacer les références tout de suite pour permettre à l'animation de s'achever
        return false
    else
        -- Si la carte a été placée, nettoyer immédiatement
        self.dragging = nil
        self.originalCard = nil
        self.cardIndex = nil
        self.targetCell = nil
        self.timer:clear() -- Annuler toute animation en cours
        
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
    return self.animating
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