-- État principal du jeu
local Garden = require('src.entities.garden')
local Constants = require('src.utils.constants')
local Config = require('src.utils.config')
local DependencyContainer = require('src.utils.dependency_container')
local Localization = require('src.utils.localization')

local GameState = {}
GameState.__index = GameState

-- Dimensions et espacements réduits de 40%
local UI_MARGIN = 6        -- 10 * 0.6
local UI_PADDING = 12      -- 20 * 0.6
local HEADER_HEIGHT = 24   -- 40 * 0.6
local TURN_INDICATOR_HEIGHT = 18 -- 30 * 0.6
local WEATHER_SECTION_HEIGHT = 30 -- 50 * 0.6
local DIE_SIZE = 24        -- 40 * 0.6
local DIE_CORNER_RADIUS = 4 -- 6 * 0.6
local BUTTON_WIDTH = 48    -- 80 * 0.6
local BUTTON_HEIGHT = 18   -- 30 * 0.6
local TEXT_SCALE = 0.6     -- Échelle de texte réduite

-- Position du plateau (réduite de 40%)
local GARDEN_TOP_MARGIN = 96 -- 160 * 0.6
local CELL_SIZE = 42       -- 70 * 0.6

-- Constructeur modifié pour accepter les dépendances
function GameState.new(dependencies)
    local self = setmetatable({}, GameState)
    
    -- Stocker les dépendances
    self.dependencies = dependencies or {}
    self.scaleManager = self.dependencies.scaleManager
    
    -- Créer un jardin ou utiliser celui fourni
    self.garden = self.dependencies.garden or Garden.new(3, 2) -- Grille 3x2 pour l'Alpha
    
    self.currentTurn = 1
    self.maxTurns = 8
    self.currentSeason = Constants.SEASON.SPRING
    self.sunDieValue = 0  -- Sera initialisé par rollDice
    self.rainDieValue = 0 -- Sera initialisé par rollDice
    self.score = 0
    self.objective = 100
    
    -- Initialiser les dés pour le premier tour
    self:rollDice()
    
    return self
end

function GameState:update(dt)
    -- Mise à jour logique
end

function GameState:draw()
    -- Utiliser les renderers via le conteneur de dépendances
    local gardenRenderer = DependencyContainer.resolve("GardenRenderer")
    
    -- Obtenir le texte de saison localisé
    local seasonText = Localization.getText(self.currentSeason)
    
    -- Interface utilisateur - haut de l'écran
    love.graphics.setColor(0.9, 0.95, 0.9)
    love.graphics.rectangle("fill", UI_MARGIN, UI_MARGIN, 580 * 0.6, HEADER_HEIGHT)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(Localization.getText("ui.saison") .. ": " .. seasonText .. " (" .. math.ceil(self.currentTurn/2) .. "/4)", UI_MARGIN + UI_PADDING, UI_MARGIN + 9, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Indicateur de tour
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", UI_MARGIN, UI_MARGIN + HEADER_HEIGHT + 6, 580 * 0.6, TURN_INDICATOR_HEIGHT)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.line(30, UI_MARGIN + HEADER_HEIGHT + 6 + TURN_INDICATOR_HEIGHT/2, 
                       UI_MARGIN + 580 * 0.6 - 30, UI_MARGIN + HEADER_HEIGHT + 6 + TURN_INDICATOR_HEIGHT/2)
    
    -- Cercles des tours
    local circleSpacing = (580 * 0.6 - 60) / 7
    for i = 1, 8 do
        local x = 30 + (i-1) * circleSpacing
        if i == self.currentTurn then
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("fill", x, UI_MARGIN + HEADER_HEIGHT + 6 + TURN_INDICATOR_HEIGHT/2, 5)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("line", x, UI_MARGIN + HEADER_HEIGHT + 6 + TURN_INDICATOR_HEIGHT/2, 5)
        end
    end
    
    -- Dés et bouton
    local weatherTop = UI_MARGIN + HEADER_HEIGHT + 6 + TURN_INDICATOR_HEIGHT + 6
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", UI_MARGIN, weatherTop, 580 * 0.6, WEATHER_SECTION_HEIGHT)
    
    -- Dé soleil
    local dieX1 = UI_MARGIN + (580 * 0.6) * 0.4
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("fill", dieX1, weatherTop + 3, DIE_SIZE, DIE_SIZE, DIE_CORNER_RADIUS)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.sunDieValue, dieX1 + 9, weatherTop + 6, 0, TEXT_SCALE, TEXT_SCALE)
    love.graphics.print(Localization.getText("ui.soleil"), dieX1 + 3, weatherTop + 18, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Dé pluie
    local dieX2 = UI_MARGIN + (580 * 0.6) * 0.55
    love.graphics.setColor(0.6, 0.8, 1)
    love.graphics.rectangle("fill", dieX2, weatherTop + 3, DIE_SIZE, DIE_SIZE, DIE_CORNER_RADIUS)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.rainDieValue, dieX2 + 9, weatherTop + 6, 0, TEXT_SCALE, TEXT_SCALE)
    love.graphics.print(Localization.getText("ui.pluie"), dieX2 + 6, weatherTop + 18, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Bouton fin de tour
    local buttonX = UI_MARGIN + (580 * 0.6) * 0.8
    love.graphics.setColor(0.6, 0.8, 0.6)
    love.graphics.rectangle("fill", buttonX, weatherTop + 6, BUTTON_WIDTH, BUTTON_HEIGHT, 3)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(Localization.getText("ui.fin_tour"), buttonX + 3, weatherTop + 12, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Score
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(Localization.getText("ui.score") .. ": " .. self.score .. "/" .. self.objective, UI_MARGIN, weatherTop + WEATHER_SECTION_HEIGHT + 6, 0, TEXT_SCALE, TEXT_SCALE)
    
    -- Dessin du jardin avec son renderer dédié
    -- Transmission de la position du jardin et de la taille des cellules
    gardenRenderer:draw(self.garden, UI_MARGIN, GARDEN_TOP_MARGIN, CELL_SIZE)
end

function GameState:mousepressed(x, y, button)
    -- Vérifier si le bouton fin de tour a été cliqué
    local weatherTop = UI_MARGIN + HEADER_HEIGHT + 6 + TURN_INDICATOR_HEIGHT + 6
    local buttonX = UI_MARGIN + (580 * 0.6) * 0.8
    
    if button == 1 and x >= buttonX and x <= buttonX + BUTTON_WIDTH and 
                       y >= weatherTop + 6 and y <= weatherTop + 6 + BUTTON_HEIGHT then
        self:nextTurn()
    end
    
    -- Vérifier si une cellule du jardin a été cliquée
    local cellX = math.floor((x - UI_MARGIN) / CELL_SIZE) + 1
    local cellY = math.floor((y - GARDEN_TOP_MARGIN) / CELL_SIZE) + 1
    
    if cellX >= 1 and cellX <= self.garden.width and 
       cellY >= 1 and cellY <= self.garden.height then
        -- Traitement du clic sur une cellule (à implémenter)
    end
end

function GameState:mousereleased(x, y, button)
    -- Rien à faire actuellement
end

function GameState:rollDice()
    -- Utiliser directement les constantes pour accéder aux plages de dés
    local seasonData = Config.diceRanges[self.currentSeason]
    
    -- Lancer les dés avec les plages de la saison
    self.sunDieValue = math.random(seasonData.sun.min, seasonData.sun.max)
    self.rainDieValue = math.random(seasonData.rain.min, seasonData.rain.max)
    
    -- Appliquer les effets météo à toutes les plantes
    self:applyWeather()
end

function GameState:applyWeather()
    for y = 1, self.garden.height do
        for x = 1, self.garden.width do
            local cell = self.garden.grid[y][x]
            if cell.plant then
                -- Appliquer effets soleil et pluie
                if self.sunDieValue > 0 then
                    cell.plant:receiveSun(self.sunDieValue)
                end
                
                if self.rainDieValue > 0 then
                    cell.plant:receiveRain(self.rainDieValue)
                end
                
                -- Vérifier gel si température négative
                if self.sunDieValue < 0 and cell.plant:checkFrost(self.sunDieValue) then
                    -- La plante gèle et meurt
                    self.garden.grid[y][x].plant = nil
                    self.garden.grid[y][x].state = Constants.CELL_STATE.EMPTY
                end
            end
        end
    end
end

function GameState:nextTurn()
    -- Récupérer le système de cartes via les dépendances ou le conteneur
    local cardSystem = self.dependencies.cardSystem or DependencyContainer.tryResolve("CardSystem")
    
    -- Piocher une carte
    if cardSystem then
        cardSystem:drawCard()
    end
    
    -- Passer au tour suivant
    self.currentTurn = self.currentTurn + 1
    
    -- Vérifier fin de partie
    if self.currentTurn > self.maxTurns then
        self.currentTurn = 1
    end
    
    -- Mettre à jour la saison
    local season = math.ceil(self.currentTurn / 2)
    if season == 1 then
        self.currentSeason = Constants.SEASON.SPRING
    elseif season == 2 then
        self.currentSeason = Constants.SEASON.SUMMER
    elseif season == 3 then
        self.currentSeason = Constants.SEASON.AUTUMN
    elseif season == 4 then
        self.currentSeason = Constants.SEASON.WINTER
    end
    
    -- Lancer les dés pour ce tour
    self:rollDice()
end

return GameState