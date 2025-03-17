-- Renderer dédié pour le jardin
local DependencyContainer = require('src.utils.dependency_container')

local GardenRenderer = {}
GardenRenderer.__index = GardenRenderer

function GardenRenderer.new()
    local self = setmetatable({}, GardenRenderer)
    return self
end

-- Méthode pour dessiner le jardin complet
function GardenRenderer:draw(garden)
    local cellWidth = 70
    local cellHeight = 70
    local offsetX = 50
    local offsetY = 180  -- Aligné avec le système de drag & drop
    
    -- Obtenir le renderer de plantes via le conteneur de dépendances
    local plantRenderer = DependencyContainer.resolve("PlantRenderer")
    
    -- Dessiner les cellules du jardin
    for y = 1, garden.height do
        for x = 1, garden.width do
            local posX = offsetX + (x-1) * cellWidth
            local posY = offsetY + (y-1) * cellHeight
            
            -- Dessiner la case
            love.graphics.setColor(0.8, 0.7, 0.5)
            love.graphics.rectangle("fill", posX, posY, cellWidth, cellHeight)
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.rectangle("line", posX, posY, cellWidth, cellHeight)
            
            -- Dessiner plante si présente, en utilisant le renderer dédié
            if garden.grid[y][x].plant then
                plantRenderer:draw(garden.grid[y][x].plant, posX, posY, cellWidth, cellHeight)
            end
        end
    end
end

return GardenRenderer