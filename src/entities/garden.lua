-- Entité Jardin (grille de jeu)
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

function Garden:placePlant(plant, x, y)
    if x > 0 and x <= self.width and y > 0 and y <= self.height then
        if not self.grid[y][x].plant then
            -- On définit les coordonnées dans l'objet Plant lui-même
            plant.posX = x
            plant.posY = y
            
            -- On place la plante dans la grille
            self.grid[y][x].plant = plant
            self.grid[y][x].state = Constants.CELL_STATE.OCCUPIED
            return true
        end
    end
    return false
end

-- Obtenir une cellule du jardin
function Garden:getCell(x, y)
    if x > 0 and x <= self.width and y > 0 and y <= self.height then
        return self.grid[y][x]
    end
    return nil
end

-- Récupérer les cellules adjacentes à une position
function Garden:getAdjacentCells(x, y)
    local adjacent = {}
    
    -- Vérifier les 4 directions (haut, droite, bas, gauche)
    local directions = {
        {x=0, y=-1}, -- haut
        {x=1, y=0},  -- droite
        {x=0, y=1},  -- bas
        {x=-1, y=0}  -- gauche
    }
    
    for _, dir in ipairs(directions) do
        local newX, newY = x + dir.x, y + dir.y
        if newX > 0 and newX <= self.width and newY > 0 and newY <= self.height then
            table.insert(adjacent, {
                x = newX,
                y = newY,
                cell = self.grid[newY][newX]
            })
        end
    end
    
    return adjacent
end

-- Récolter une plante
function Garden:harvestPlant(x, y)
    if x > 0 and x <= self.width and y > 0 and y <= self.height then
        local cell = self.grid[y][x]
        if cell.plant and cell.plant.growthStage == Constants.GROWTH_STAGE.FRUIT then
            local score = cell.plant:harvest()
            cell.plant = nil
            cell.state = Constants.CELL_STATE.EMPTY
            return score
        end
    end
    return 0
end

return Garden