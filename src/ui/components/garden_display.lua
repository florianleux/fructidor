-- Composant d'affichage du jardin simplifié
local ComponentBase = require('src.ui.components.component_base')

local GardenDisplay = setmetatable({}, {__index = ComponentBase})
GardenDisplay.__index = GardenDisplay

function GardenDisplay.new(params)
    local self = setmetatable(ComponentBase.new(params), GardenDisplay)
    
    -- Paramètres spécifiques à l'affichage du jardin
    self.garden = params.garden
    self.gardenRenderer = params.gardenRenderer
    self.dragDrop = params.dragDrop
    
    -- Taille des cellules du jardin
    self.cellSize = 70
    
    -- Espacement entre les cellules
    self.cellSpacing = 5
    
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
        highlight = {0.8, 1, 0.8, 0.3} -- Surbrillance pour les cellules ciblées
    }
    
    -- Calculer les dimensions du jardin
    self:calculateGardenDimensions()
    
    return self
end

function GardenDisplay:calculateGardenDimensions()
    -- Calculer la largeur et hauteur totales du jardin
    self.gardenWidth = self.garden.width * (self.cellSize + self.cellSpacing) - self.cellSpacing
    self.gardenHeight = self.garden.height * (self.cellSize + self.cellSpacing) - self.cellSpacing
    
    -- Calculer la position pour centrer le jardin dans le composant
    self.gardenX = self.x + (self.width - self.gardenWidth) / 2
    self.gardenY = self.y + (self.height - self.gardenHeight) / 2
end

function GardenDisplay:draw()
    -- Mettre à jour les dimensions
    self:calculateGardenDimensions()
    
    -- Dessiner le fond du composant
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Utiliser le renderer de jardin pour dessiner le jardin
    if self.gardenRenderer then
        self.gardenRenderer:draw(self.garden, self.gardenX, self.gardenY, self.cellSize, self.cellSpacing)
    else
        -- Dessiner un jardin de base si le renderer n'est pas disponible
        self:drawBasicGarden()
    end
    
    -- Dessiner les surbrillances pour le drag & drop si nécessaire
    if self.dragDrop and self.dragDrop:isDragging() then
        local mouseX, mouseY = love.mouse.getPosition()
        mouseX = mouseX / (self.scaleManager.scale or 1)
        mouseY = mouseY / (self.scaleManager.scale or 1)
        
        -- Vérifier quelle cellule est survolée
        local cellX, cellY = self:getCellAt(mouseX, mouseY)
        
        if cellX >= 1 and cellX <= self.garden.width and cellY >= 1 and cellY <= self.garden.height then
            -- Dessiner la surbrillance sur la cellule ciblée
            local cellScreenX, cellScreenY = self:getCellCoordinates(cellX, cellY)
            
            love.graphics.setColor(unpack(self.colors.highlight))
            love.graphics.rectangle("fill", cellScreenX, cellScreenY, self.cellSize, self.cellSize, 3)
        end
    end
end

function GardenDisplay:drawBasicGarden()
    -- Dessiner la grille de base du jardin (utilisé si gardenRenderer n'est pas disponible)
    for y = 1, self.garden.height do
        for x = 1, self.garden.width do
            local cellX, cellY = self:getCellCoordinates(x, y)
            
            -- Fond de la cellule
            love.graphics.setColor(unpack(self.colors.cellBackground))
            love.graphics.rectangle("fill", cellX, cellY, self.cellSize, self.cellSize, 3)
            
            -- Bordure de la cellule
            love.graphics.setColor(unpack(self.colors.cellBorder))
            love.graphics.rectangle("line", cellX, cellY, self.cellSize, self.cellSize, 3)
            
            -- Si la cellule contient une plante, afficher une représentation simple
            local cell = self.garden.grid[y][x]
            if cell and cell.plant then
                love.graphics.setColor(0.5, 0.8, 0.5) -- Vert pour les plantes
                love.graphics.rectangle("fill", cellX + 10, cellY + 10, self.cellSize - 20, self.cellSize - 20, 2)
                
                -- Afficher le stade de croissance
                love.graphics.setColor(0, 0, 0)
                love.graphics.print(cell.plant.growthStage, cellX + self.cellSize/2 - 5, cellY + self.cellSize/2 - 5)
            end
            
            -- Si la cellule contient un objet, afficher une représentation simple
            if cell and cell.object then
                love.graphics.setColor(0.8, 0.7, 0.5) -- Marron clair pour les objets
                love.graphics.rectangle("fill", cellX + 15, cellY + 15, self.cellSize - 30, self.cellSize - 30, 2)
            end
        end
    end
end

function GardenDisplay:getCellCoordinates(gridX, gridY)
    -- Convertir les coordonnées de la grille en coordonnées d'écran
    local cellX = self.gardenX + (gridX - 1) * (self.cellSize + self.cellSpacing)
    local cellY = self.gardenY + (gridY - 1) * (self.cellSize + self.cellSpacing)
    
    return cellX, cellY
end

function GardenDisplay:getCellAt(x, y)
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

function GardenDisplay:mousepressed(x, y, button)
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
            if cell.plant and cell.plant.growthStage == "mature" then
                -- Logique pour récolter la plante
                return true -- Le clic a été traité
            end
        end
    end
    
    return false -- Le clic n'a pas été traité
end

function GardenDisplay:updateGarden()
    -- Cette méthode est appelée pour rafraîchir l'affichage du jardin
    -- quand son contenu change (nouvelle plante, plante récoltée, etc.)
    
    -- Pour l'instant, il suffit de laisser le système de dessin récupérer 
    -- les données directement depuis le jardin à chaque frame
    
    -- Si besoin d'optimisation, on pourrait implémenter un cache ici
end

return GardenDisplay