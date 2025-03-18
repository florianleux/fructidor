-- Système de Drag & Drop
local Services = require('src.utils.services')
local Constants = require('src.utils.constants')

local DragDrop = {}
DragDrop.__index = DragDrop

-- Utilisation des constantes centralisées
local CARD_WIDTH = Constants.UI.CARD.WIDTH
local CARD_HEIGHT = Constants.UI.CARD.HEIGHT
local CARD_CORNER_RADIUS = Constants.UI.CARD.CORNER_RADIUS
local CARD_HEADER_HEIGHT = Constants.UI.CARD.HEADER_HEIGHT
local TEXT_SCALE = Constants.UI.CARD.TEXT_SCALE

-- Constantes d'animation
local ANIMATION_DURATION = 0.3 -- Durée de l'animation en secondes
local CARD_SCALE_WHEN_DRAGGED = 0.6 -- Taille réduite
local RETURN_ANIMATION_DURATION = 0.3 -- Durée de l'animation de retour en ligne droite

function DragDrop.new(dependencies)
    local self = setmetatable({}, DragDrop)
    self.dragging = nil -- carte en cours de déplacement
    self.originalCard = nil -- sauvegarde des informations de la carte
    self.cardIndex = nil -- indice de la carte dans la main
    
    -- Stocker les dépendances
    self.dependencies = dependencies or {}
    self.scaleManager = self.dependencies.scaleManager
    
    -- État de l'animation de déplacement
    self.moveAnimation = {
        active = false,
        startTime = 0,
        duration = RETURN_ANIMATION_DURATION,
        startX = 0,
        startY = 0,
        targetX = 0,
        targetY = 0,
        startScale = 1.0,
        targetScale = 1.0,
        currentScale = 1.0
    }
    
    return self
end

function DragDrop:update(dt)
    -- Mettre à jour l'animation de mouvement si active
    if self.moveAnimation.active then
        local currentTime = love.timer.getTime()
        local elapsedTime = currentTime - self.moveAnimation.startTime
        
        if elapsedTime >= self.moveAnimation.duration then
            -- Animation terminée
            if self.dragging then
                self.dragging.x = self.moveAnimation.targetX
                self.dragging.y = self.moveAnimation.targetY
                self.moveAnimation.currentScale = self.moveAnimation.targetScale
            end
            
            -- Informer le système de cartes que nous avons terminé
            self:endAnimation()
            
        else
            -- Animation en cours
            local progress = elapsedTime / self.moveAnimation.duration
            
            -- Fonction d'easing pour une animation plus fluide (outQuad)
            progress = 1 - (1 - progress) * (1 - progress)
            
            -- Mettre à jour la position et l'échelle
            if self.dragging then
                self.dragging.x = self.moveAnimation.startX + 
                                 (self.moveAnimation.targetX - self.moveAnimation.startX) * progress
                self.dragging.y = self.moveAnimation.startY + 
                                 (self.moveAnimation.targetY - self.moveAnimation.startY) * progress
                self.moveAnimation.currentScale = self.moveAnimation.startScale + 
                                                (self.moveAnimation.targetScale - self.moveAnimation.startScale) * progress
            end
        end
    end
    
    -- Mettre à jour la position de la carte si en cours de déplacement
    if self.dragging and not self.moveAnimation.active then
        -- Utiliser les coordonnées ajustées à l'échelle
        local mouseX, mouseY
        if self.scaleManager then
            mouseX = love.mouse.getX() / self.scaleManager.scale
            mouseY = love.mouse.getY() / self.scaleManager.scale
        else
            mouseX = love.mouse.getX()
            mouseY = love.mouse.getY()
        end
        
        self.dragging.x = mouseX
        self.dragging.y = mouseY
    end
end

function DragDrop:startDrag(card, cardIndex, cardSystem)
    -- Ignorer si une animation est déjà en cours
    if self.moveAnimation.active then return end
    
    -- Sauvegarder la carte originale et son indice
    self.originalCard = card
    self.cardIndex = cardIndex
    
    -- Stocker la référence au système de cartes
    if cardSystem then
        self.dependencies.cardSystem = cardSystem
    end
    
    -- Créer une copie pour le drag & drop
    self.dragging = {}
    for k, v in pairs(card) do
        self.dragging[k] = v
    end
    
    -- Initialiser la position au centre du curseur
    local mouseX, mouseY
    if self.scaleManager then
        mouseX = love.mouse.getX() / self.scaleManager.scale
        mouseY = love.mouse.getY() / self.scaleManager.scale
    else
        mouseX = love.mouse.getX()
        mouseY = love.mouse.getY()
    end
    
    self.dragging.x = mouseX
    self.dragging.y = mouseY
    
    -- Initialiser l'échelle réduite directement
    self.moveAnimation.currentScale = CARD_SCALE_WHEN_DRAGGED
end

function DragDrop:stopDrag(garden)
    if not self.dragging or not self.originalCard or self.moveAnimation.active then 
        return false 
    end
    
    local placed = false
    
    -- Récupérer le composant GardenDisplay via les services
    local uiManager = self.dependencies.uiManager or Services.get("UIManager")
    local gardenDisplay = nil
    
    if uiManager and uiManager.components and uiManager.components.gardenDisplay then
        gardenDisplay = uiManager.components.gardenDisplay
    end
    
    -- Trouver la cellule sous la carte
    for y = 1, garden.height do
        for x = 1, garden.width do
            local cellX, cellY, isInside
            
            -- Utiliser les coordonnées du GardenDisplay si disponible
            if gardenDisplay then
                cellX, cellY = gardenDisplay:getCellCoordinates(x, y)
                isInside = self.dragging.x >= cellX and 
                           self.dragging.x < cellX + gardenDisplay.cellSize and
                           self.dragging.y >= cellY and 
                           self.dragging.y < cellY + gardenDisplay.cellSize
            else
                -- Fallback avec des valeurs codées en dur (éviter si possible)
                local cellSize = 42
                local gardenX = 96 -- Position X estimée du jardin
                local gardenY = 216 -- Position Y estimée du jardin
                
                cellX = gardenX + (x-1) * cellSize
                cellY = gardenY + (y-1) * cellSize
                isInside = self.dragging.x >= cellX and 
                           self.dragging.x < cellX + cellSize and
                           self.dragging.y >= cellY and 
                           self.dragging.y < cellY + cellSize
            end
            
            if isInside then
                -- Tenter de placer la plante
                if not garden.grid[y][x].plant then
                    local cardSystem = self.dependencies.cardSystem or Services.get("CardSystem")
                    if self.cardIndex and cardSystem then
                        placed = cardSystem:playCard(self.cardIndex, garden, x, y)
                    end
                end
                
                break
            end
        end
        if placed then break end
    end
    
    -- Si la carte n'a pas été placée, animer son retour à la main en ligne droite
    if not placed then
        -- Initialiser l'animation de retour
        self.moveAnimation.active = true
        self.moveAnimation.startTime = love.timer.getTime()
        self.moveAnimation.duration = RETURN_ANIMATION_DURATION
        self.moveAnimation.startX = self.dragging.x
        self.moveAnimation.startY = self.dragging.y
        self.moveAnimation.targetX = self.originalCard.x
        self.moveAnimation.targetY = self.originalCard.y
        self.moveAnimation.startScale = CARD_SCALE_WHEN_DRAGGED
        self.moveAnimation.targetScale = 1.0
        
        return false
    else
        -- Si la carte a été placée, nettoyer immédiatement
        self:endAnimation()
        return placed
    end
end

-- Méthode centralisée pour terminer le drag & drop
function DragDrop:endAnimation()
    -- Nettoyage des ressources
    self.dragging = nil
    self.originalCard = nil
    self.cardIndex = nil
    self.moveAnimation.active = false
end

function DragDrop:updateHighlight(garden, x, y)
    -- Ne pas afficher de surbrillance si une animation est en cours
    if self.moveAnimation.active or not self.dragging then return end
    
    -- Récupérer le composant GardenDisplay via les services
    local uiManager = self.dependencies.uiManager or Services.get("UIManager")
    local gardenDisplay = nil
    
    if uiManager and uiManager.components and uiManager.components.gardenDisplay then
        gardenDisplay = uiManager.components.gardenDisplay
    end
    
    -- Réinitialiser les surbrillances
    for cy = 1, garden.height do
        for cx = 1, garden.width do
            local cellX, cellY, cellSize
            
            if gardenDisplay then
                cellX, cellY = gardenDisplay:getCellCoordinates(cx, cy)
                cellSize = gardenDisplay.cellSize
            else
                -- Fallback avec des valeurs codées en dur
                cellSize = 42
                local gardenX = 96
                local gardenY = 216
                cellX = gardenX + (cx-1) * cellSize
                cellY = gardenY + (cy-1) * cellSize
            end
            
            local highlight = x >= cellX and x < cellX + cellSize and
                             y >= cellY and y < cellY + cellSize and
                             not garden.grid[cy][cx].plant
            
            if highlight then
                love.graphics.setColor(0.8, 0.9, 0.7, 0.6)
                love.graphics.rectangle("fill", cellX, cellY, cellSize, cellSize)
                love.graphics.setColor(0.4, 0.8, 0.4)
                love.graphics.rectangle("line", cellX, cellY, cellSize, cellSize, 2)
            end
        end
    end
end

function DragDrop:isDragging()
    return self.dragging ~= nil
end

function DragDrop:getDraggingCard()
    return self.dragging
end

function DragDrop:getDraggingCardIndex()
    return self.cardIndex
end

function DragDrop:isAnimating()
    return self.moveAnimation.active
end

function DragDrop:draw()
    -- Dessiner la carte en cours de déplacement ou d'animation
    if self.dragging then
        local card = self.dragging
        
        -- Obtenir l'échelle actuelle
        local scale = self.moveAnimation.currentScale
        
        -- Appliquer l'échelle aux dimensions de la carte
        local scaledWidth = CARD_WIDTH * scale
        local scaledHeight = CARD_HEIGHT * scale
        local scaledHeaderHeight = CARD_HEADER_HEIGHT * scale
        
        -- Calculer les positions ajustées pour la carte
        local cardLeft = card.x - scaledWidth/2
        local cardTop = card.y - scaledHeight/2
        
        -- Dessiner une ombre
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 
            cardLeft + 2 * scale, 
            cardTop + 2 * scale, 
            scaledWidth, scaledHeight, CARD_CORNER_RADIUS)
        
        -- Dessiner la carte elle-même
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", cardLeft, cardTop, scaledWidth, scaledHeight, CARD_CORNER_RADIUS)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("line", cardLeft, cardTop, scaledWidth, scaledHeight, CARD_CORNER_RADIUS)
        
        -- Couleur de fond selon la famille
        if card.color then
            love.graphics.setColor(card.color)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
        end
        love.graphics.rectangle("fill", cardLeft + 3 * scale, cardTop + 3 * scale, 
                               scaledWidth - 6 * scale, scaledHeaderHeight)
        
        -- Calculer l'échelle du texte pour les cartes redimensionnées
        local textScale = TEXT_SCALE * scale
        
        -- Nom et info
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(card.family, cardLeft + 6 * scale, cardTop + 5 * scale, 0, textScale, textScale)
        love.graphics.print("Graine", cardLeft + 6 * scale, cardTop + 21 * scale, 0, textScale, textScale)
        
        -- Besoins pour pousser
        love.graphics.print("☀️ " .. card.sunToSprout, cardLeft + 6 * scale, cardTop + 36 * scale, 0, textScale, textScale)
        love.graphics.print("🌧️ " .. card.rainToSprout, cardLeft + 6 * scale, cardTop + 51 * scale, 0, textScale, textScale)
        
        -- Score
        love.graphics.print(card.baseScore .. " pts", cardLeft + 6 * scale, cardTop + 66 * scale, 0, textScale, textScale)
        
        -- Gel
        love.graphics.print("❄️ " .. card.frostThreshold, cardLeft + 6 * scale, cardTop + 81 * scale, 0, textScale, textScale)
    end
end

return DragDrop