-- État principal du jeu
local Garden = require('src.entities.garden')

local GameState = {}
GameState.__index = GameState

function GameState.new()
    local self = setmetatable({}, GameState)
    self.garden = Garden.new(3, 2) -- Grille 3x2 pour l'Alpha
    self.currentTurn = 1
    self.maxTurns = 8
    self.currentSeason = "Printemps"
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
    -- Dessin du jardin
    self.garden:draw()
    
    -- Interface utilisateur
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Tour: " .. self.currentTurn .. "/" .. self.maxTurns, 10, 10)
    love.graphics.print("Saison: " .. self.currentSeason, 150, 10)
    love.graphics.print("Soleil: " .. self.sunDieValue, 300, 10)
    love.graphics.print("Pluie: " .. self.rainDieValue, 400, 10)
    love.graphics.print("Score: " .. self.score .. "/" .. self.objective, 500, 10)
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
    local config = require('src.utils.config')
    local seasonData
    
    if self.currentSeason == "Printemps" then
        seasonData = config.diceRanges.spring
    elseif self.currentSeason == "Été" then
        seasonData = config.diceRanges.summer
    elseif self.currentSeason == "Automne" then
        seasonData = config.diceRanges.autumn
    else -- Hiver
        seasonData = config.diceRanges.winter
    end
    
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
                end
            end
        end
    end
end

function GameState:nextTurn()
    -- Passer au tour suivant
    self.currentTurn = self.currentTurn + 1
    
    -- Mettre à jour la saison
    local season = math.ceil(self.currentTurn / 2)
    if season == 1 then
        self.currentSeason = "Printemps"
    elseif season == 2 then
        self.currentSeason = "Été"
    elseif season == 3 then
        self.currentSeason = "Automne"
    elseif season == 4 then
        self.currentSeason = "Hiver"
    end
    
    -- Lancer les dés pour ce tour
    self:rollDice()
end

return GameState
