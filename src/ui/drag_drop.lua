-- Système de Drag & Drop
local DragDrop = {}
DragDrop.__index = DragDrop

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
        
        -- Dessiner une ombre
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 
            card.x - 30 + 4, 
            card.y - 50 + 4, 
            60, 100, 3)
        
        -- Dessiner la carte elle-même
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", card.x - 30, card.y - 50, 60, 100, 3)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("line", card.x - 30, card.y - 50, 60, 100, 3)
        
        -- Couleur de fond selon la famille
        if card.color then
            love.graphics.setColor(card.color)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
        end
        love.graphics.rectangle("fill", card.x - 25, card.y - 45, 50, 15)
        
        -- Nom et info
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(card.family, card.x - 25, card.y - 45)
        love.graphics.print("Graine", card.x - 25, card.y - 25)
        
        -- Besoins pour pousser
        love.graphics.print("☀️ " .. card.sunToSprout, card.x - 25, card.y - 5)
        love.graphics.print("🌧️ " .. card.rainToSprout, card.x - 25, card.y + 10)
        
        -- Score
        love.graphics.print(card.baseScore .. " pts", card.x - 25, card.y + 25)
        
        -- Gel
        love.graphics.print("❄️ " .. card.frostThreshold, card.x - 25, card.y + 40)
    end
end

return DragDrop