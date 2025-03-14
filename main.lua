-- Point d'entrée principal Fructidor
local GameState = require('src.states.game_state')

function love.load()
    -- Initialisation du jeu
    gameState = GameState.new()
end

function love.update(dt)
    -- Mise à jour logique du jeu
    gameState:update(dt)
end

function love.draw()
    -- Rendu du jeu
    gameState:draw()
end

function love.mousepressed(x, y, button)
    gameState:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    gameState:mousereleased(x, y, button)
end
