-- Composant unifié du jardin (fusion de GardenRenderer et GardenDisplay)
local ComponentBase = require('src.ui.components.component_base')
local GameConfig = require('src.utils.game_config')

local GardenComponent = {}
GardenComponent.__index = GardenComponent

-- Constantes de rendu
local TEXT_SCALE = 0.6 -- Échelle de texte réduite

function GardenComponent.new(params)
    local self = {}
    setmetatable(self, GardenComponent)
    
    -- Attributs de base (copier explicitement ComponentBase)
    self.x = params.x or 0
    self.y = params.y or 0
    self.width = params.width or 100
    self.height = params.height or 100
    self.visible = params.visible ~= false
    self.id = params.id or "garden"
    self.scaleManager = params.scaleManager
    
    -- IMPORTANT: Références directes sans l'ajout d'une couche indirecte
    self.garden = params.model or params.garden
    self.dragDrop = params.dragDrop
    self.onHarvest = params.onHarvest
    
    -- Initialiser un jardin par défaut si nécessaire
    if not self.garden then
        self.garden = {
            width = 3,
            height = 2,
            grid = {}
        }
        
        -- Initialiser la grille
        for y = 1, self.garden.height do
            self.garden.grid[y] = {}
            for x = 1, self.garden.width do
                self.garden.grid[y][x] = {
                    plant = nil,
                    object = nil,
                    state = GameConfig.CELL_STATE.EMPTY
                }
            end
        end
    end
    
    -- Taille des cellules du jardin
    self.cellSize = params.cellSize or 70
    
    -- Espacement entre les cellules
    self.cellSpacing = params.cellSpacing or 5
    
    -- Position et dimensions du jardin à l'écran
    self.gardenX = 0
    self.gardenY = 0
    self.gardenWidth = 0
    self.gardenHeight = 0
    
    -- Couleurs
    self.colors = {
        background = {0.95, 0.9, 0.8, 1}, -- Couleur terre claire
        cellBorder = {0.6, 0.45, 0.3, 1}, -- Marron pour les bordures
        cellBackground = {0.85, 0.75, 0.6, 1}, -- Terre pour les cellules
        grid = {0.7, 0.6, 0.4, 1}, -- Lignes de grille
        highlight = {0.8, 1, 0.8, 0.3}, -- Surbrillance pour les cellules ciblées
        earth = {0.9, 0.8, 0.6, 1}, -- Couleur de la terre
        border = {0.7, 0.6, 0.4, 1}, -- Bordure des cellules
        text = {0, 0, 0, 1} -- Texte
    }
    
    -- Calculer les dimensions du jardin
    self:calculateGardenDimensions()
    
    return self
end

-- Méthode explicite pour rafraîchir le composant
function GardenComponent:refreshGarden()
    -- Recalculer les dimensions
    self:calculateGardenDimensions()
end

function GardenComponent:calculateGardenDimensions()
    -- Calculer la largeur et hauteur totales du jardin
    self.gardenWidth = self.garden.width * (self.cellSize + self.cellSpacing) - self.cellSpacing
    self.gardenHeight = self.garden.height * (self.cellSize + self.cellSpacing) - self.cellSpacing
    
    -- Calculer la position pour centrer le jardin dans le composant
    self.gardenX = self.x + (self.width - self.gardenWidth) / 2
    self.gardenY = self.y + (self.height - self.gardenHeight) / 2
end

function GardenComponent:draw()
    -- Vérifier si le jardiin existe
    if not self.garden then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("Erreur: garden est nil", self.x + 10, self.y + 10)
        return
    end
    
    -- Mettre à jour les dimensions
    self:calculateGardenDimensions()
    
    -- Dessiner le fond du composant
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Dessiner le fond du jardin
    love.graphics.setColor(unpack(self.colors.earth))
    love.graphics.rectangle("fill", self.gardenX, self.gardenY, self.gardenWidth, self.gardenHeight)
    
    -- Dessiner les cellules du jardin
    for cy = 1, self.garden.height do
        for cx = 1, self.garden.width do
            local cellX, cellY = self:getCellCoordinates(cx, cy)
            
            -- Dessiner le contour de la cellule
            love.graphics.setColor(unpack(self.colors.border))
            love.graphics.rectangle("line", cellX, cellY, self.cellSize, self.cellSize)
            
            -- Dessiner le contenu de la cellule
            local cell = self.garden.grid[cy][cx]
            if cell and cell.plant then
                -- Dessiner la plante en utilisant sa couleur
                if type(cell.plant.color) == "table" then
                    love.graphics.setColor(cell.plant.color[1], cell.plant.color[2], cell.plant.color[3])
                else
                    -- Fallback sur vert si la couleur n'est pas une table
                    love.graphics.setColor(0.5, 0.8, 0.5)
                end
                
                -- Dessiner en fonction du stade de croissance
                if cell.plant.growthStage == GameConfig.GROWTH_STAGE.SEED then
                    -- Graine: petit cercle
                    love.graphics.circle("fill", cellX + self.cellSize/2, cellY + self.cellSize/2, self.cellSize/6)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.circle("line", cellX + self.cellSize/2, cellY + self.cellSize/2, self.cellSize/6)
                elseif cell.plant.growthStage == GameConfig.GROWTH_STAGE.SPROUT then
                    -- Pousse: rectangle arrondi moyen
                    love.graphics.rectangle("fill", cellX + self.cellSize/4, cellY + self.cellSize/4, self.cellSize/2, self.cellSize/2, 3, 3)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("line", cellX + self.cellSize/4, cellY + self.cellSize/4, self.cellSize/2, self.cellSize/2, 3, 3)
                elseif cell.plant.growthStage == GameConfig.GROWTH_STAGE.FRUIT then
                    -- Fructifié: rectangle arrondi presque plein
                    local padding = 3
                    love.graphics.rectangle("fill", cellX + padding, cellY + padding, 
                                         self.cellSize - 2*padding, self.cellSize - 2*padding, 3, 3)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("line", cellX + padding, cellY + padding, 
                                         self.cellSize - 2*padding, self.cellSize - 2*padding, 3, 3)
                end
                
                -- Afficher les infos de la plante
                love.graphics.setColor(unpack(self.colors.text))
                
                -- Afficher la famille au-dessus
                local familyText = cell.plant.family:sub(1, 3) -- Abréviation
                love.graphics.print(familyText, cellX + 3, cellY + 3, 0, TEXT_SCALE, TEXT_SCALE)
                
                -- Afficher le stade en bas
                local stageText = "Graine"
                if cell.plant.growthStage == GameConfig.GROWTH_STAGE.SPROUT then
                    stageText = "Plant"
                elseif cell.plant.growthStage == GameConfig.GROWTH_STAGE.FRUIT then
                    stageText = "Mûr"
                end
                love.graphics.print(stageText, cellX + 3, cellY + self.cellSize - 12, 0, TEXT_SCALE, TEXT_SCALE)
                
                -- Afficher les compteurs de soleil et pluie
                local sunNeeded, rainNeeded
                
                if cell.plant.growthStage == GameConfig.GROWTH_STAGE.SEED then
                    sunNeeded = cell.plant.sunToSprout
                    rainNeeded = cell.plant.rainToSprout
                else
                    sunNeeded = cell.plant.sunToFruit
                    rainNeeded = cell.plant.rainToFruit
                end
                
                local sunText = "\226\152\128\239\184\143" .. cell.plant.accumulatedSun .. "/" .. sunNeeded
                local rainText = "\240\159\140\167\239\184\143" .. cell.plant.accumulatedRain .. "/" .. rainNeeded
                
                love.graphics.print(sunText, cellX + 3, cellY + self.cellSize - 24, 0, TEXT_SCALE, TEXT_SCALE)
                love.graphics.print(rainText, cellX + 3, cellY + self.cellSize - 36, 0, TEXT_SCALE, TEXT_SCALE)
            end
            
            -- Dessiner un objet s'il existe
            if cell and cell.object then
                -- TODO: implémenter dessin des objets
            end
        end
    end
    
    -- Dessiner les surbrillances pour le drag & drop si nécessaire
    if self.dragDrop and self.dragDrop:isDragging() then
        local mouseX, mouseY = love.mouse.getPosition()
        mouseX = mouseX / (self.scaleManager and self.scaleManager.scale or 1)
        mouseY = mouseY / (self.scaleManager and self.scaleManager.scale or 1)
        
        -- Vérifier quelle cellule est survolée
        local cellX, cellY = self:getCellAt(mouseX, mouseY)
        
        -- Vérifier que cellX et cellY ne sont pas nil avant la comparaison
        if cellX and cellY and cellX >= 1 and cellX <= self.garden.width and cellY >= 1 and cellY <= self.garden.height then
            -- Dessiner la surbrillance sur la cellule ciblée
            local cellScreenX, cellScreenY = self:getCellCoordinates(cellX, cellY)
            
            love.graphics.setColor(unpack(self.colors.highlight))
            love.graphics.rectangle("fill", cellScreenX, cellScreenY, self.cellSize, self.cellSize, 3)
        end
    end
end

function GardenComponent:getCellCoordinates(gridX, gridY)
    -- Convertir les coordonnées de la grille en coordonnées d'écran
    local cellX = self.gardenX + (gridX - 1) * (self.cellSize + self.cellSpacing)
    local cellY = self.gardenY + (gridY - 1) * (self.cellSize + self.cellSpacing)
    
    return cellX, cellY
end

function GardenComponent:getCellAt(x, y)
    -- Vérifier si les coordonnées sont dans les limites du jardin
    if x < self.gardenX or y < self.gardenY or x > self.gardenX + self.gardenWidth or y > self.gardenY + self.gardenHeight then
        return nil, nil
    end
    
    -- Calculer les indices de la cellule
    local cellX = math.floor((x - self.gardenX) / (self.cellSize + self.cellSpacing)) + 1
    local cellY = math.floor((y - self.gardenY) / (self.cellSize + self.cellSpacing)) + 1
    
    -- Vérifier que les indices sont valides
    if cellX >= 1 and cellX <= self.garden.width and cellY >= 1 and cellY <= self.garden.height then
        return cellX, cellY
    else
        return nil, nil
    end
end

function GardenComponent:mousepressed(x, y, button)
    -- Vérifier si le clic est sur une cellule
    local cellX, cellY = self:getCellAt(x, y)
    
    if cellX and cellY and button == 1 then
        -- Traiter le clic sur la cellule
        local cell = self.garden.grid[cellY][cellX]
        
        -- Si la carte en cours de déplacement peut être placée ici
        if self.dragDrop and self.dragDrop:isDragging() then
            local card = self.dragDrop:getDraggingCard()
            
            -- Vérifier si on peut placer la carte ici
            if card and card.type == "plant" and not cell.plant then
                -- Logique pour placer une plante
                return true -- Le clic a été traité
            elseif card and card.type == "object" and not cell.object then
                -- Logique pour placer un objet
                return true -- Le clic a été traité
            end
        else
            -- Si une plante est à maturité, la récolter
            if cell.plant and cell.plant.growthStage == GameConfig.GROWTH_STAGE.FRUIT then
                local score = self.garden:harvestPlant(cellX, cellY)
                -- Informer le système de score du gain
                if self.onHarvest and score > 0 then
                    self.onHarvest(score)
                end
                return true -- Le clic a été traité
            end
        end
    end
    
    return false -- Le clic n'a pas été traité
end

-- Implémentation des méthodes de ComponentBase
function GardenComponent:containsPoint(x, y)
    return self.visible and 
           x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function GardenComponent:getBounds()
    return self.x, self.y, self.width, self.height
end

function GardenComponent:update(dt)
    -- Pas besoin de logique spécifique pour l'instant
end

function GardenComponent:mousereleased(x, y, button)
    return false
end

function GardenComponent:mousemoved(x, y, dx, dy)
    return false
end

return GardenComponent