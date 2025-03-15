-- Système de Drag & Drop
local DragDrop = {}
DragDrop.__index = DragDrop

-- Définition des constantes pour la taille des cartes (180% de la taille originale)
local CARD_WIDTH = 108  -- 60 * 1.8
local CARD_HEIGHT = 180 -- 100 * 1.8
local CARD_CORNER_RADIUS = 5
local CARD_HEADER_HEIGHT = 27 -- 15 * 1.8
local TEXT_PADDING_X = 45 -- 25 * 1.8 
local TEXT_LINE_HEIGHT = 18 -- Ajusté pour les cartes plus grandes

function DragDrop.new()
    local self = setmetatable({}, DragDrop)
    self.dragging = nil -- carte en cours de déplacement
    self.originalCard = nil -- sauvegarde des informations de la carte
    self.cardIndex = nil -- indice de la carte dans la main
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.targetCell = nil -- cellule cible surbrillance
    
    return self
end

function DragDrop:startDrag(card, cardIndex, x, y)
    -- Sauvegarder la carte originale et son indice
    self.originalCard = card
    self.cardIndex = cardIndex
    
    -- Créer une copie pour le drag & drop
    self.dragging = {}
    for k, v in pairs(card) do
        self.dragging[k] = v
    end
    
    -- Calcul des offsets pour centrer la carte sous le curseur
    self.dragOffsetX = 0 -- La carte sera centrée sur le curseur
    self.dragOffsetY = 0
    
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
    
    -- Réinitialiser l'état du système de cartes
    if not placed and cardSystem then
        cardSystem:resetDragging()
    end
    
    -- Réinitialiser l'état de drag & drop
    self.dragging = nil
    self.originalCard = nil
    self.cardIndex = nil
    self.targetCell = nil
    
    return placed
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

function DragDrop:draw()
    -- Dessiner la carte en cours de déplacement
    if self.dragging then
        local card = self.dragging
        -- Calculer les positions ajustées pour la carte agrandie
        local cardLeft = card.x - CARD_WIDTH/2
        local cardTop = card.y - CARD_HEIGHT/2
        
        -- Dessiner une ombre
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 
            cardLeft + 4, 
            cardTop + 4, 
            CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
        
        -- Dessiner la carte elle-même
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("line", cardLeft, cardTop, CARD_WIDTH, CARD_HEIGHT, CARD_CORNER_RADIUS)
        
        -- Couleur de fond selon la famille
        if card.color then
            love.graphics.setColor(card.color)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
        end
        love.graphics.rectangle("fill", cardLeft + 5, cardTop + 5, CARD_WIDTH - 10, CARD_HEADER_HEIGHT)
        
        -- Échelle du texte pour les cartes plus grandes
        local textScale = 1.4
        
        -- Nom et info
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(card.family, cardLeft + 10, cardTop + 9, 0, textScale, textScale)
        love.graphics.print("Graine", cardLeft + 10, cardTop + 35, 0, textScale, textScale)
        
        -- Besoins pour pousser
        love.graphics.print("☀️ " .. card.sunToSprout, cardLeft + 10, cardTop + 60, 0, textScale, textScale)
        love.graphics.print("🌧️ " .. card.rainToSprout, cardLeft + 10, cardTop + 85, 0, textScale, textScale)
        
        -- Score
        love.graphics.print(card.baseScore .. " pts", cardLeft + 10, cardTop + 110, 0, textScale, textScale)
        
        -- Gel
        love.graphics.print("❄️ " .. card.frostThreshold, cardLeft + 10, cardTop + 135, 0, textScale, textScale)
    end
end

return DragDrop