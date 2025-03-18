-- Gestionnaire d'interface utilisateur simplifié
local UIManager = {}
UIManager.__index = UIManager

-- Importer les dépendances
local LayoutManager = require('src.ui.layout_manager')
local SeasonBanner = require('src.ui.components.season_banner')
local WeatherDice = require('src.ui.components.weather_dice')
local GardenDisplay = require('src.ui.components.garden_display')
local ScorePanel = require('src.ui.components.score_panel')
local HandDisplay = require('src.ui.components.hand_display')

function UIManager.new(params)
    local self = setmetatable({}, UIManager)
    
    -- Obtenir les dépendances
    self.gameState = params.gameState
    self.cardSystem = params.cardSystem
    self.dragDrop = params.dragDrop
    self.garden = params.garden
    self.scaleManager = params.scaleManager
    self.gardenRenderer = params.gardenRenderer
    
    -- Référence à la fonction pour passer au tour suivant
    self.nextTurnCallback = params.nextTurnCallback
    
    -- Initialiser le gestionnaire de mise en page
    self.layoutManager = LayoutManager.new({
        scaleManager = self.scaleManager
    })
    
    -- Créer les composants d'interface
    self:createComponents()
    
    return self
end

function UIManager:createComponents()
    -- Définir les dimensions de base (basées sur une résolution de 1920x1080)
    local width = love.graphics.getWidth() / (self.scaleManager.scale or 1)
    local height = love.graphics.getHeight() / (self.scaleManager.scale or 1)
    
    -- Panneau de score (en haut à droite)
    local scorePanel = ScorePanel.new({
        x = width * 0.75,
        y = 0,
        width = width * 0.25,
        height = height * 0.15,
        gameState = self.gameState,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", scorePanel)
    
    -- Bannière de saison (en haut à gauche)
    local seasonBanner = SeasonBanner.new({
        x = 0,
        y = 0,
        width = width * 0.75,
        height = height * 0.07,
        gameState = self.gameState,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", seasonBanner)
    
    -- Composant dés météo et bouton fin de tour
    local weatherDice = WeatherDice.new({
        x = width * 0.1,
        y = height * 0.09,
        width = width * 0.8,
        height = height * 0.08,
        gameState = self.gameState,
        endTurnCallback = self.nextTurnCallback,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", weatherDice)
    
    -- Affichage du potager
    local gardenDisplay = GardenDisplay.new({
        x = width * 0.05,
        y = height * 0.2,
        width = width * 0.9,
        height = height * 0.55,
        garden = self.garden,
        gardenRenderer = self.gardenRenderer,
        dragDrop = self.dragDrop,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", gardenDisplay)
    
    -- Affichage de la main du joueur
    local handDisplay = HandDisplay.new({
        x = 0,
        y = height * 0.75,
        width = width,
        height = height * 0.25,
        cardSystem = self.cardSystem,
        dragDrop = self.dragDrop,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", handDisplay)
    
    -- Stocker des références aux composants principaux pour accès rapide
    self.components = {
        seasonBanner = seasonBanner,
        weatherDice = weatherDice,
        gardenDisplay = gardenDisplay,
        handDisplay = handDisplay,
        scorePanel = scorePanel
    }
end

function UIManager:draw()
    -- Dessiner tous les composants via le gestionnaire de mise en page
    self.layoutManager:draw()
end

function UIManager:update(dt)
    -- Mettre à jour tous les composants
    self.layoutManager:update(dt)
end

function UIManager:mousepressed(x, y, button)
    -- Transmettre l'événement au gestionnaire de mise en page
    return self.layoutManager:mousepressed(x, y, button)
end

function UIManager:mousereleased(x, y, button)
    -- Transmettre l'événement au gestionnaire de mise en page
    return self.layoutManager:mousereleased(x, y, button)
end

function UIManager:mousemoved(x, y, dx, dy)
    -- Transmettre l'événement au gestionnaire de mise en page
    return self.layoutManager:mousemoved(x, y, dx, dy)
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

-- Méthode simplifiée pour les animations
function UIManager:triggerAnimation(componentId, animationType, ...)
    local component = self.components[componentId]
    if component then
        if componentId == "scorePanel" and animationType == "scoreChange" and component.animateScoreChange then
            component:animateScoreChange(...)
        elseif componentId == "weatherDice" and animationType == "rolling" and component.startRolling then
            component:startRolling(...)
        end
    end
end

return UIManager