-- Gestionnaire d'interface utilisateur
-- Utilise la nouvelle architecture unifiée KISS des composants
local UIManager = {}
UIManager.__index = UIManager

-- Importer les composants unifiés
local SeasonComponent = require('src.ui.components.season_component')
local WeatherComponent = require('src.ui.components.weather_component')
local GardenComponent = require('src.ui.components.garden_component')
local ScoreComponent = require('src.ui.components.score_component')
local HandComponent = require('src.ui.components.hand_component')

function UIManager.new(params)
    local self = setmetatable({}, UIManager)
    
    -- Obtenir les dépendances par injection directe
    self.gameState = params.gameState
    self.cardSystem = params.cardSystem
    self.dragDrop = params.dragDrop
    self.garden = params.garden
    self.scaleManager = params.scaleManager
    self.nextTurnCallback = params.nextTurnCallback
    
    -- Conteneur pour les composants
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
    
    -- Créer les composants principaux avec le modèle KISS
    self.components.scorePanel = ScoreComponent.new({
        x = width * 0.75,
        y = 0,
        width = width * 0.25,
        height = height * 0.15,
        model = self.gameState, -- Référence au modèle
        scaleManager = self.scaleManager
    })
    
    self.components.seasonBanner = SeasonComponent.new({
        x = 0,
        y = 0,
        width = width * 0.75,
        height = height * 0.07,
        model = self.gameState, -- Référence au modèle
        scaleManager = self.scaleManager
    })
    
    self.components.weatherDice = WeatherComponent.new({
        x = width * 0.1,
        y = height * 0.09,
        width = width * 0.8,
        height = height * 0.08,
        model = self.gameState, -- Référence au modèle
        endTurnCallback = self.nextTurnCallback,
        scaleManager = self.scaleManager
    })
    
    -- Composant jardin unifié
    self.components.garden = GardenComponent.new({
        x = width * 0.05,
        y = height * 0.2,
        width = 800,
        height = height * 400,
        model = self.garden, -- Référence au modèle
        dragDrop = self.dragDrop,
        scaleManager = self.scaleManager,
        onHarvest = function(score)
            -- Callback pour mettre à jour le score lors d'une récolte
            self.gameState:addScore(score)
            self.components.scorePanel:refreshScore(score)
        end
    })
    
    -- Composant main unifié
    self.components.hand = HandComponent.new({
        x = 0,
        y = height * 0.7,
        width = width,
        height = height * 0.3,
        model = self.cardSystem, -- Référence au modèle
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
        -- Utiliser les méthodes refresh* standardisées de l'architecture unifiée
        if componentId == "hand" and component.refreshHand then
            component:refreshHand()
        elseif componentId == "garden" and component.refreshGarden then
            component:refreshGarden()
        elseif componentId == "seasonBanner" and component.refreshSeason then
            component:refreshSeason()
        elseif componentId == "weatherDice" and component.refreshDice then
            component:refreshDice()
        elseif componentId == "scorePanel" and component.refreshScore then
            component:refreshScore()
        end
    end
end

-- Pour rétrocompatibilité: mapper les anciens IDs vers les nouveaux
local legacyComponentMap = {
    handDisplay = "hand",
    gardenDisplay = "garden"
}

-- Méthode de compatibilité avec l'ancien système
function UIManager:getLegacyComponent(componentId)
    local newId = legacyComponentMap[componentId] or componentId
    return self.components[newId]
end

return UIManager