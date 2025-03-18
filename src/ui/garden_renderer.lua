-- Renderer dédié pour le jardin
local Constants = require('src.utils.constants')
local DependencyContainer = require('src.utils.dependency_container')

local GardenRenderer = {}
GardenRenderer.__index = GardenRenderer

-- Constantes de rendu (réduites de 40%)
local CELL_DEFAULT_SIZE = 42  -- 70 * 0.6
local CELL_PADDING = 3        -- 5 * 0.6
local TEXT_SCALE = 0.6        -- Échelle de texte réduite

function GardenRenderer.new()
    local self = setmetatable({}, GardenRenderer)
    -- Par défaut, position en haut à gauche
    self.x = 0
    self.y = 0
    self.cellSize = CELL_DEFAULT_SIZE
    return self
end

-- Méthode pour définir la position absolue du jardin
function GardenRenderer:setPosition(x, y, cellSize)
    self.x = x or self.x
    self.y = y or self.y
    self.cellSize = cellSize or self.cellSize
end

-- Méthode pour dessiner le jardin avec les plantes
function GardenRenderer:draw(garden)
    -- Utiliser la position absolue stockée
    local x = self.x
    local y = self.y
    local size = self.cellSize
    
    -- Dessiner le fond du jardin
    love.graphics.setColor(0.9, 0.8, 0.6) -- Couleur terre/sable
    love.graphics.rectangle("fill", x, y, garden.width * size, garden.height * size)
    
    -- Dessiner les cellules du jardin
    for cy = 1, garden.height do
        for cx = 1, garden.width do
            local cellX = x + (cx - 1) * size
            local cellY = y + (cy - 1) * size
            
            -- Couleur de fond de la cellule selon son état
            local cell = garden.grid[cy][cx]
            
            -- Dessiner le contour de la cellule
            love.graphics.setColor(0.7, 0.6, 0.4) -- Brun foncé pour les bordures
            love.graphics.rectangle("line", cellX, cellY, size, size)
            
            -- Dessiner le contenu de la cellule
            if cell.plant then
                -- Dessiner la plante en utilisant sa couleur
                love.graphics.setColor(cell.plant.color[1], cell.plant.color[2], cell.plant.color[3])
                
                -- Dessiner en fonction du stade de croissance
                if cell.plant.growthStage == Constants.GROWTH_STAGE.SEED then
                    -- Graine: petit cercle
                    love.graphics.circle("fill", cellX + size/2, cellY + size/2, size/6)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.circle("line", cellX + size/2, cellY + size/2, size/6)
                elseif cell.plant.growthStage == Constants.GROWTH_STAGE.SPROUT then
                    -- Pousse: rectangle arrondi moyen
                    love.graphics.rectangle("fill", cellX + size/4, cellY + size/4, size/2, size/2, 3, 3)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("line", cellX + size/4, cellY + size/4, size/2, size/2, 3, 3)
                elseif cell.plant.growthStage == Constants.GROWTH_STAGE.FRUIT then
                    -- Fructifié: rectangle arrondi presque plein
                    love.graphics.rectangle("fill", cellX + CELL_PADDING, cellY + CELL_PADDING, 
                                          size - 2*CELL_PADDING, size - 2*CELL_PADDING, 3, 3)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("line", cellX + CELL_PADDING, cellY + CELL_PADDING, 
                                          size - 2*CELL_PADDING, size - 2*CELL_PADDING, 3, 3)
                end
                
                -- Afficher les infos de la plante
                love.graphics.setColor(0, 0, 0)
                
                -- Afficher la famille au-dessus
                local familyText = cell.plant.family:sub(1, 3) -- Abréviation
                love.graphics.print(familyText, cellX + 3, cellY + 3, 0, TEXT_SCALE, TEXT_SCALE)
                
                -- Afficher le stade en bas
                local stageText = "Graine"
                if cell.plant.growthStage == Constants.GROWTH_STAGE.SPROUT then
                    stageText = "Plant"
                elseif cell.plant.growthStage == Constants.GROWTH_STAGE.FRUIT then
                    stageText = "Mûr"
                end
                love.graphics.print(stageText, cellX + 3, cellY + size - 12, 0, TEXT_SCALE, TEXT_SCALE)
                
                -- Afficher les compteurs de soleil et pluie
                local sunText = "☀️" .. cell.plant.accumulatedSun .. "/" .. cell.plant.sunToFruit
                local rainText = "🌧️" .. cell.plant.accumulatedRain .. "/" .. cell.plant.rainToFruit
                
                if cell.plant.growthStage == Constants.GROWTH_STAGE.SEED then
                    sunText = "☀️" .. cell.plant.accumulatedSun .. "/" .. cell.plant.sunToSprout
                    rainText = "🌧️" .. cell.plant.accumulatedRain .. "/" .. cell.plant.rainToSprout
                end
                
                love.graphics.print(sunText, cellX + 3, cellY + size - 24, 0, TEXT_SCALE, TEXT_SCALE)
                love.graphics.print(rainText, cellX + 3, cellY + size - 36, 0, TEXT_SCALE, TEXT_SCALE)
            end
            
            -- Dessiner un objet s'il existe
            if cell.object then
                -- TODO: implémenter dessin des objets
            end
        end
    end
end

-- Conversion de coordonnées screen en coordonnées de grille
function GardenRenderer:getGridCoordinates(screenX, screenY)
    local gridX = math.floor((screenX - self.x) / self.cellSize) + 1
    local gridY = math.floor((screenY - self.y) / self.cellSize) + 1
    return gridX, gridY
end

-- Vérifier si les coordonnées écran sont dans le jardin
function GardenRenderer:containsPoint(garden, screenX, screenY)
    local gridX, gridY = self:getGridCoordinates(screenX, screenY)
    return gridX >= 1 and gridX <= garden.width and gridY >= 1 and gridY <= garden.height
end

return GardenRenderer