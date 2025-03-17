-- État principal du jeu
local Garden = require('src.entities.garden')
local Constants = require('src.utils.constants')
local Config = require('src.utils.config')
local DependencyContainer = require('src.utils.dependency_container')
local Localization = require('src.utils.localization')

local GameState = {}
GameState.__index = GameState

-- Constructeur modifié pour accepter les dépendances
function GameState.new(dependencies)
    local self = setmetatable({}, GameState)
    
    -- Stocker les dépendances
    self.dependencies = dependencies or {}
    
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
    
    -- Dessin du jardin avec son renderer dédié
    gardenRenderer:draw(self.garden)
    
    -- Convertir constante en texte pour affichage via le système de localisation
    local seasonText = Localization.getText(self.currentSeason)
    
    -- Interface utilisateur - haut de l'écran
    love.graphics.setColor(0.9, 0.95, 0.9)
    love.graphics.rectangle("fill", 10, 10, 580, 40)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(Localization.getText("ui.saison") .. ": " .. seasonText .. " (" .. math.ceil(self.currentTurn/2) .. "/4)", 30, 25)
    
    -- Indicateur de tour
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", 10, 60, 580, 30)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.line(50, 75, 550, 75)
    
    -- Cercles des tours
    for i = 1, 8 do
        local x = 50 + (i-1) * 500/7
        if i == self.currentTurn then
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("fill", x, 75, 8)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("line", x, 75, 8)
        end
    end
    
    -- Dés et bouton
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", 10, 100, 580, 50)
    
    -- Dé soleil
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("fill", 240, 105, 40, 40, 6)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.sunDieValue, 255, 115)
    love.graphics.print(Localization.getText("ui.soleil"), 245, 130)
    
    -- Dé pluie
    love.graphics.setColor(0.6, 0.8, 1)
    love.graphics.rectangle("fill", 310, 105, 40, 40, 6)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.rainDieValue, 325, 115)
    love.graphics.print(Localization.getText("ui.pluie"), 317, 130)
    
    -- Bouton fin de tour
    love.graphics.setColor(0.6, 0.8, 0.6)
    love.graphics.rectangle("fill", 480, 110, 80, 30, 5)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(Localization.getText("ui.fin_tour"), 487, 120)
    
    -- Score
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(Localization.getText("ui.score") .. ": " .. self.score .. "/" .. self.objective, 10, 160)
end

function GameState:mousepressed(x, y, button)
    -- Vérifier si le bouton fin de tour a été cliqué
    if button == 1 and x >= 480 and x <= 560 and y >= 110 and y <= 140 then
        self:nextTurn()
    end
end

function GameState:mousereleased(x, y, button)
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