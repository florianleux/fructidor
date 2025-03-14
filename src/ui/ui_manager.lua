-- Gestionnaire d'interface utilisateur
local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local self = setmetatable({}, UIManager)
    return self
end

function UIManager:draw(gameState)
    -- Interface tour et saison
    love.graphics.setColor(0.9, 0.95, 0.9)
    love.graphics.rectangle("fill", 10, 10, 580, 40)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Saison: " .. gameState.currentSeason .. " (" .. math.ceil(gameState.currentTurn/2) .. "/4)", 30, 25)
    
    -- Indicateur de tour
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", 10, 60, 580, 30)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.line(50, 75, 550, 75)
    
    -- Dessiner les cercles de tour
    for i = 1, 8 do
        local x = 50 + (i-1) * 500/7
        if i == gameState.currentTurn then
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("fill", x, 75, 8)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("line", x, 75, 8)
        end
    end
    
    -- Dés météo
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("fill", 240, 105, 40, 40, 6)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(gameState.sunDieValue, 255, 115)
    love.graphics.print("Soleil", 245, 130)
    
    love.graphics.setColor(0.6, 0.8, 1)
    love.graphics.rectangle("fill", 310, 105, 40, 40, 6)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(gameState.rainDieValue, 325, 115)
    love.graphics.print("Pluie", 317, 130)
    
    -- Bouton fin de tour
    love.graphics.setColor(0.6, 0.8, 0.6)
    love.graphics.rectangle("fill", 480, 110, 80, 30, 5)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Fin du tour", 487, 120)
end

return UIManager
