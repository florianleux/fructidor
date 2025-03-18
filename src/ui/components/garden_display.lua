-- Composant d'affichage du potager
local ComponentBase = require('src.ui.components.component_base')

local GardenDisplay = setmetatable({}, {__index = ComponentBase})
GardenDisplay.__index = GardenDisplay

function GardenDisplay.new(params)
    local self = ComponentBase.new({
        id = "garden_display",
        pixelX = params.pixelX or 96,      -- 5% de 1920
        pixelY = params.pixelY or 216,     -- 20% de 1080
        pixelWidth = params.pixelWidth or 1728,   -- 90% de 1920
        pixelHeight = params.pixelHeight or 540,  -- 50% de 1080
        margin = params.margin or {top=10, right=10, bottom=10, left=10},
        scaleManager = params.scaleManager
    })
    
    setmetatable(self, GardenDisplay)
    
    -- Référence au jardin
    self.garden = params.garden
    
    -- Référence au renderer du jardin (optionnel)
    self.gardenRenderer = params.gardenRenderer
    
    -- Référence au système de drag & drop
    self.dragDrop = params.dragDrop
    
    -- Couleurs du sol du jardin
    self.soilColor = {0.91, 0.82, 0.69}  -- Marron clair
    self.soilBorderColor = {0.8, 0.7, 0.6}  -- Marron plus foncé
    
    -- Grille de cellules calculée
    self.cells = {}
    
    -- Définir les tailles proportionnellement à l'espace disponible
    self:calculateCellDimensions()
    
    return self
end

-- Calcule les dimensions des cellules du jardin en fonction de l'espace disponible
function GardenDisplay:calculateCellDimensions()
    if not self.garden then return end
    
    local availableWidth = self.width
    local availableHeight = self.height
    
    -- Calculer la taille optimale des cellules en fonction des dimensions du jardin
    local cellWidth = availableWidth / self.garden.width
    local cellHeight = availableHeight / self.garden.height
    
    -- Utiliser la plus petite dimension pour des cellules carrées
    self.cellSize = math.min(cellWidth, cellHeight)
    
    -- Calculer l'offset pour centrer le jardin
    self.offsetX = (availableWidth - (self.cellSize * self.garden.width)) / 2
    self.offsetY = (availableHeight - (self.cellSize * self.garden.height)) / 2
    
    -- Recalculer les positions de toutes les cellules
    self.cells = {}
    for y = 1, self.garden.height do
        self.cells[y] = {}
        for x = 1, self.garden.width do
            local cellX = self.x + self.offsetX + (x-1) * self.cellSize
            local cellY = self.y + self.offsetY + (y-1) * self.cellSize
            
            self.cells[y][x] = {
                x = cellX,
                y = cellY,
                width = self.cellSize,
                height = self.cellSize
            }
        end
    end
end

-- Convertit les coordonnées écran en coordonnées de cellule
function GardenDisplay:screenToCell(screenX, screenY)
    for y = 1, self.garden.height do
        for x = 1, self.garden.width do
            local cell = self.cells[y][x]
            if screenX >= cell.x and screenX < cell.x + cell.width and
               screenY >= cell.y and screenY < cell.y + cell.height then
                return x, y
            end
        end
    end
    return nil, nil
end

-- Détermine si un point est dans les limites du jardin
function GardenDisplay:containsPoint(x, y)
    if not self.visible then return false end
    
    local result = ComponentBase.containsPoint(self, x, y)
    if result then
        -- Vérifier si le point est spécifiquement dans une cellule
        local cellX, cellY = self:screenToCell(x, y)
        return cellX ~= nil and cellY ~= nil
    end
    return false
end

function GardenDisplay:draw()
    if not self.visible or not self.garden then return end
    
    -- Dessiner le fond du jardin
    love.graphics.setColor(0.82, 0.70, 0.55)  -- Couleur terre plus foncée
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Recalculer les dimensions si nécessaire
    if #self.cells == 0 or self.cells[1] == nil or #self.cells[1] == 0 then
        self:calculateCellDimensions()
    end
    
    -- Dessiner toutes les cellules
    for y = 1, self.garden.height do
        for x = 1, self.garden.width do
            local cell = self.cells[y][x]
            
            -- Fond de la cellule (terre)
            love.graphics.setColor(self.soilColor)
            love.graphics.rectangle("fill", cell.x, cell.y, cell.width, cell.height)
            
            -- Bordure de la cellule
            love.graphics.setColor(self.soilBorderColor)
            love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height)
            
            -- Si nous avons un renderer de jardin, l'utiliser pour dessiner le contenu de la cellule
            if self.gardenRenderer then
                self.gardenRenderer:drawCell(x, y, cell.x, cell.y, cell.width, cell.height)
            else
                -- Dessin de base si pas de renderer spécifique
                local plantInfo = self.garden:getPlantAt(x, y)
                if plantInfo then
                    -- Dessiner une représentation simple de la plante
                    if plantInfo.growthStage == "graine" then
                        love.graphics.setColor(0.6, 0.4, 0.2)  -- Marron
                        love.graphics.circle("fill", cell.x + cell.width/2, cell.y + cell.height/2, cell.width/10)
                    elseif plantInfo.growthStage == "plant" then
                        love.graphics.setColor(0.5, 0.8, 0.3)  -- Vert clair
                        love.graphics.circle("fill", cell.x + cell.width/2, cell.y + cell.height/2, cell.width/5)
                    elseif plantInfo.growthStage == "fructifié" then
                        love.graphics.setColor(0.3, 0.7, 0.3)  -- Vert plus foncé
                        love.graphics.circle("fill", cell.x + cell.width/2, cell.y + cell.height/2, cell.width/4)
                        
                        -- Indiquer qu'elle est prête à être récoltée
                        love.graphics.setColor(1, 1, 0)  -- Jaune
                        love.graphics.circle("line", cell.x + cell.width/2, cell.y + cell.height/2, cell.width/3)
                    end
                    
                    -- Texte d'information
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.setFont(love.graphics.newFont(math.max(8, cell.width/10)))
                    love.graphics.printf(plantInfo.family, cell.x, cell.y + cell.height/4, cell.width, "center")
                    love.graphics.printf(plantInfo.growthStage, cell.x, cell.y + cell.height/2, cell.width, "center")
                end
                
                -- Dessiner l'objet s'il y en a un
                local objectInfo = self.garden:getObjectAt(x, y)
                if objectInfo then
                    love.graphics.setColor(0.9, 0.8, 0.7)  -- Beige
                    love.graphics.rectangle("fill", cell.x + cell.width/4, cell.y + cell.width/4, 
                                           cell.width/2, cell.height/2)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.setFont(love.graphics.newFont(math.max(8, cell.width/12)))
                    love.graphics.printf(objectInfo.name, cell.x, cell.y + 3*cell.height/4, cell.width, "center")
                end
            end
            
            -- Surbrillance des cellules pour le drag & drop
            if self.dragDrop and self.dragDrop:isHighlighted(x, y) then
                local canPlace = self.dragDrop:canPlaceAtCell(x, y)
                
                -- Couleur selon si on peut placer ou non
                if canPlace then
                    love.graphics.setColor(0, 1, 0, 0.3)  -- Vert transparent (OK)
                else
                    love.graphics.setColor(1, 0, 0, 0.3)  -- Rouge transparent (impossible)
                end
                
                love.graphics.rectangle("fill", cell.x, cell.y, cell.width, cell.height)
                love.graphics.setColor(canPlace and {0, 1, 0, 0.7} or {1, 0, 0, 0.7})
                love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height)
            end
        end
    end
    
    -- Dessiner les bordures extérieures plus épaisses
    love.graphics.setColor(0.6, 0.5, 0.4)
    love.graphics.setLineWidth(3)
    local gardenX = self.x + self.offsetX
    local gardenY = self.y + self.offsetY
    local gardenWidth = self.cellSize * self.garden.width
    local gardenHeight = self.cellSize * self.garden.height
    love.graphics.rectangle("line", gardenX, gardenY, gardenWidth, gardenHeight)
    love.graphics.setLineWidth(1)
end

function GardenDisplay:update(dt)
    -- Pas d'animation spécifique pour le moment
end

function GardenDisplay:calculateBounds(parentX, parentY, parentWidth, parentHeight)
    -- Appeler la méthode de la classe parente
    ComponentBase.calculateBounds(self, parentX, parentY, parentWidth, parentHeight)
    
    -- Recalculer les dimensions des cellules après le repositionnement
    self:calculateCellDimensions()
end

function GardenDisplay:mousepressed(x, y, button)
    if not self.visible or not self.garden then return false end
    
    local cellX, cellY = self:screenToCell(x, y)
    if not cellX or not cellY then return false end
    
    if button == 1 then
        -- Clic gauche: Récolter une plante si elle est prête
        local plantInfo = self.garden:getPlantAt(cellX, cellY)
        if plantInfo and plantInfo.growthStage == "fructifié" then
            self.garden:harvestPlant(cellX, cellY)
            return true
        end
    elseif button == 2 then
        -- Clic droit: Afficher des informations détaillées
        local plantInfo = self.garden:getPlantAt(cellX, cellY)
        if plantInfo then
            -- TODO: Afficher une infobulle ou un panneau d'information
            print("Plante en (" .. cellX .. "," .. cellY .. "): " .. plantInfo.family)
            return true
        end
    end
    
    return false
end

return GardenDisplay
