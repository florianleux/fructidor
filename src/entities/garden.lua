-- Entité Jardin (grille de jeu)
local Plant = require('src.entities.plant')
local Constants = require('src.utils.constants')

local Garden = {}
Garden.__index = Garden

function Garden.new(width, height)
    local self = setmetatable({}, Garden)
    self.width = width
    self.height = height
    self.grid = {}
    
    -- Initialiser grille vide
    for y = 1, height do
        self.grid[y] = {}
        for x = 1, width do
            self.grid[y][x] = {
                plant = nil, 
                object = nil, 
                state = Constants.CELL_STATE.EMPTY
            }
        end
    end
    
    return self
end

function Garden:draw()
    local cellWidth = 70
    local cellHeight = 70
    local offsetX = 50
    local offsetY = 180  -- Modifié de 50 à 180 pour aligner avec le système de drag & drop
    
    -- Dessiner les cellules
    for y = 1, self.height do
        for x = 1, self.width do
            local posX = offsetX + (x-1) * cellWidth
            local posY = offsetY + (y-1) * cellHeight
            
            -- Dessiner la case
            love.graphics.setColor(0.8, 0.7, 0.5)
            love.graphics.rectangle("fill", posX, posY, cellWidth, cellHeight)
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.rectangle("line", posX, posY, cellWidth, cellHeight)
            
            -- Dessiner plante si présente
            if self.grid[y][x].plant then
                self.grid[y][x].plant:draw(posX, posY, cellWidth, cellHeight)
            end
        end
    end
end

function Garden:placePlant(plant, x, y)
    if x > 0 and x <= self.width and y > 0 and y <= self.height then
        if not self.grid[y][x].plant then
            self.grid[y][x].plant = plant
            self.grid[y][x].state = Constants.CELL_STATE.OCCUPIED
            plant.posX = x
            plant.posY = y
            return true
        end
    end
    return false
end

return Garden