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
    self.sunDieValue = 3
    self.rainDieValue = 4
    self.score = 0
    self.objective = 100
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
end

function GameState:mousereleased(x, y, button)
end

return GameState
