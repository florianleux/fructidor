-- Gestionnaire d'interface utilisateur
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
    -- Panneau de score (repositionné en haut à droite)
    local scorePanel = ScorePanel.new({
        pixelX = 1440,    -- 75% de 1920
        pixelY = 0,
        pixelWidth = 480, -- 25% de 1920
        pixelHeight = 162, -- 15% de 1080
        gameState = self.gameState,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", scorePanel)
    
    -- Bannière de saison (en haut à gauche)
    local seasonBanner = SeasonBanner.new({
        pixelX = 0,
        pixelY = 0,
        pixelWidth = 1440, -- 75% de 1920
        pixelHeight = 76,  -- 7% de 1080
        gameState = self.gameState,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", seasonBanner)
    
    -- Composant dés météo et bouton fin de tour
    local weatherDice = WeatherDice.new({
        pixelX = 192,     -- 10% de 1920
        pixelY = 97,      -- 9% de 1080
        pixelWidth = 1536, -- 80% de 1920
        pixelHeight = 86,  -- 8% de 1080
        gameState = self.gameState,
        endTurnCallback = self.nextTurnCallback,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", weatherDice)
    
    -- Affichage du potager (agrandi pour utiliser plus d'espace horizontal)
    local gardenDisplay = GardenDisplay.new({
        pixelX = 96,      -- 5% de 1920
        pixelY = 216,     -- 20% de 1080
        pixelWidth = 1728, -- 90% de 1920
        pixelHeight = 594, -- 55% de 1080
        garden = self.garden,
        gardenRenderer = self.gardenRenderer,
        dragDrop = self.dragDrop,
        scaleManager = self.scaleManager
    })
    self.layoutManager:addComponent("main", gardenDisplay)
    
    -- Affichage de la main du joueur
    local handDisplay = HandDisplay.new({
        pixelX = 0,
        pixelY = 810,     -- 75% de 1080
        pixelWidth = 1920, -- 100% de 1920
        pixelHeight = 270, -- 25% de 1080
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
    -- (à implémenter dans layout_manager.lua)
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
        end
    end
end

-- Méthode pour déclencher une animation (comme un changement de score)
function UIManager:triggerAnimation(componentId, animationType, ...)
    local component = self.components[componentId]
    if component then
        if componentId == "scorePanel" and animationType == "scoreChange" and component.animateScoreChange then
            component:animateScoreChange(...)
        elseif componentId == "weatherDice" and animationType == "rolling" and component.startRolling then
            component:startRolling()
        end
    end
end

return UIManager
