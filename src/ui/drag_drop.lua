-- Système de Drag & Drop
local DragDrop = {}
DragDrop.__index = DragDrop

function DragDrop.new()
    local self = setmetatable({}, DragDrop)
    self.dragging = nil -- carte en cours de déplacement
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.targetCell = nil -- cellule cible surbrillance
    
    return self
end

function DragDrop:startDrag(card, x, y)
    self.dragging = card
    self.dragOffsetX = card.x - x
    self.dragOffsetY = card.y - y
end

function DragDrop:updateDrag(x, y)
    if not self.dragging then return end
    
    self.dragging.x = x + self.dragOffsetX
    self.dragging.y = y + self.dragOffsetY
end

function DragDrop:stopDrag(garden, cardSystem)
    if not self.dragging then return false end
    
    local card = self.dragging
    local placed = false
    
    -- Trouver la cellule sous la carte
    for y = 1, garden.height do
        for x = 1, garden.width do
            local posX = 50 + (x-1) * 70
            local posY = 180 + (y-1) * 70
            
            if card.x >= posX and card.x < posX + 70 and
               card.y >= posY and card.y < posY + 70 then
                
                -- Tenter de placer la plante
                if not garden.grid[y][x].plant then
                    local cardIndex = nil
                    
                    -- Trouver l'index de la carte dans la main
                    for i, handCard in ipairs(cardSystem.hand) do
                        if handCard == card then
                            cardIndex = i
                            break
                        end
                    end
                    
                    if cardIndex then
                        placed = cardSystem:playCard(cardIndex, garden, x, y)
                    end
                end
                
                break
            end
        end
        if placed then break end
    end
    
    self.dragging = nil
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
        -- Dessiner une ombre
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 
            self.dragging.x - 30 + 4, 
            self.dragging.y - 50 + 4, 
            60, 100, 3)
        
        -- Dessiner la carte elle-même
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", self.dragging.x - 30, self.dragging.y - 50, 60, 100, 3)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("line", self.dragging.x - 30, self.dragging.y - 50, 60, 100, 3)
        
        -- Dessiner le contenu de la carte
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.dragging.family, self.dragging.x - 20, self.dragging.y - 30)
        love.graphics.print("Graine", self.dragging.x - 20, self.dragging.y - 15)
    end
end

return DragDrop