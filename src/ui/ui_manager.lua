-- Gestionnaire d'interface utilisateur simplifié
local UIManager = {}
UIManager.__index = UIManager

-- Importer les composants
local SeasonBanner = require('src.ui.components.season_banner')
local WeatherDice = require('src.ui.components.weather_dice')
local GardenDisplay = require('src.ui.components.garden_display')
local ScorePanel = require('src.ui.components.score_panel')
local HandDisplay = require('src.ui.components.hand_display')

function UIManager.new(params)
    local self = setmetatable({}, UIManager)
    
    -- Obtenir les dépendances par injection directe
    self.gameState = params.gameState
    self.cardSystem = params.cardSystem
    self.dragDrop = params.dragDrop
    self.garden = params.garden
    self.scaleManager = params.scaleManager
    self.gardenRenderer = params.gardenRenderer
    self.nextTurnCallback = params.nextTurnCallback
    
    -- Conteneur simplifié pour les composants
    self.components = {}
    
    -- Créer les composants d'interface
    self:createComponents()
    
    return self
end

function UIManager:createComponents()
    -- Calculs de base pour le positionnement
    local width = love.graphics.getWidth() / (self.scaleManager.scale or 1)
    local height = love.graphics.getHeight() / (self.scaleManager.scale or 1)
    
    -- Ajuster l'espace pour la main de cartes
    local cardHandHeight = height * 0.25
    
    -- Créer les composants principaux
    self.components.scorePanel = ScorePanel.new({
        x = width * 0.75,
        y = 0,
        width = width * 0.25,
        height = height * 0.15,
        gameState = self.gameState,
        scaleManager = self.scaleManager
    })
    
    self.components.seasonBanner = SeasonBanner.new({
        x = 0,
        y = 0,
        width = width * 0.75,
        height = height * 0.07,
        gameState = self.gameState,
        scaleManager = self.scaleManager
    })
    
    self.components.weatherDice = WeatherDice.new({
        x = width * 0.1,
        y = height * 0.09,
        width = width * 0.8,
        height = height * 0.08,
        gameState = self.gameState,
        endTurnCallback = self.nextTurnCallback,
        scaleManager = self.scaleManager
    })
    
    -- Réduire la hauteur du jardin et le placer plus haut pour éviter le chevauchement
    self.components.gardenDisplay = GardenDisplay.new({
        x = width * 0.05,
        y = height * 0.2,
        width = width * 0.9,
        height = height * 0.45, -- Réduit de 0.55 à 0.45
        garden = self.garden,
        gardenRenderer = self.gardenRenderer,
        dragDrop = self.dragDrop,
        scaleManager = self.scaleManager
    })
    
    -- Créer une zone claire pour la main de cartes
    self.components.handDisplay = HandDisplay.new({
        x = 0,
        y = height * 0.7, -- Monter de 0.75 à 0.7
        width = width,
        height = height * 0.3, -- Augmenter de 0.25 à 0.3
        cardSystem = self.cardSystem,
        dragDrop = self.dragDrop,
        scaleManager = self.scaleManager
    })
end

function UIManager:draw()
    -- Dessiner chaque composant dans l'ordre
    for _, component in pairs(self.components) do
        if component.visible ~= false then
            component:draw()
        end
    end
end

function UIManager:update(dt)
    -- Mettre à jour chaque composant
    for _, component in pairs(self.components) do
        if component.update then
            component:update(dt)
        end
    end
end

function UIManager:mousepressed(x, y, button)
    -- Vérifier quel composant a capturé l'événement
    for _, component in pairs(self.components) do
        if component.mousepressed and component:containsPoint(x, y) then
            if component:mousepressed(x, y, button) then
                return true -- Événement traité
            end
        end
    end
    return false -- Aucun composant n'a traité l'événement
end

function UIManager:mousereleased(x, y, button)
    -- Vérifier quel composant a capturé l'événement
    for _, component in pairs(self.components) do
        if component.mousereleased and component:containsPoint(x, y) then
            if component:mousereleased(x, y, button) then
                return true -- Événement traité
            end
        end
    end
    return false -- Aucun composant n'a traité l'événement
end

function UIManager:mousemoved(x, y, dx, dy)
    -- Vérifier quel composant a capturé l'événement
    for _, component in pairs(self.components) do
        if component.mousemoved then
            if component:mousemoved(x, y, dx, dy) then
                return true -- Événement traité
            end
        end
    end
    return false -- Aucun composant n'a traité l'événement
end

-- Méthode pour actualiser un composant spécifique
function UIManager:updateComponent(componentId)
    local component = self.components[componentId]
    if component then
        -- Appeler une méthode spécifique si elle existe
        if componentId == "handDisplay" and component.updateHand then
            component:updateHand()
        elseif componentId == "gardenDisplay" and component.updateGarden then
            component:updateGarden()
        elseif componentId == "seasonBanner" and component.updateSeason then
            component:updateSeason()
        elseif componentId == "weatherDice" and component.updateDice then
            component:updateDice()
        elseif componentId == "scorePanel" and component.updateScore then
            component:updateScore()
        end
    end
end

return UIManager