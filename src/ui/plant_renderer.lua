-- Renderer dédié pour les plantes
local Constants = require('src.utils.constants')
local Localization = require('src.utils.localization')

local PlantRenderer = {}
PlantRenderer.__index = PlantRenderer

function PlantRenderer.new()
    local self = setmetatable({}, PlantRenderer)
    return self
end

-- Méthode pour dessiner une plante à une position donnée
function PlantRenderer:draw(plant, x, y, width, height)
    -- Couleur selon stade de croissance
    if plant.growthStage == Constants.GROWTH_STAGE.SEED then
        love.graphics.setColor(0.6, 0.6, 0.4)
    elseif plant.growthStage == Constants.GROWTH_STAGE.PLANT then
        love.graphics.setColor(0.4, 0.7, 0.4)
    elseif plant.growthStage == Constants.GROWTH_STAGE.FRUITING then
        love.graphics.setColor(0.3, 0.8, 0.3)
    end
    
    -- Dessiner la plante
    love.graphics.rectangle("fill", x+5, y+5, width-10, height-10)
    
    -- Obtenir les textes localisés
    local familyText = Localization.getText(plant.family)
    local stageText = Localization.getText(plant.growthStage)
    
    -- Afficher infos
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(familyText, x+10, y+15)
    love.graphics.print(stageText, x+10, y+30)
    
    -- Afficher besoins et progression
    local sunNeed = plant.growthStage == Constants.GROWTH_STAGE.SEED and plant.sunToSprout or plant.sunToFruit
    local rainNeed = plant.growthStage == Constants.GROWTH_STAGE.SEED and plant.rainToSprout or plant.rainToFruit
    
    love.graphics.print("☀️" .. plant.accumulatedSun .. "/" .. sunNeed, x+10, y+45)
    love.graphics.print("🌧️" .. plant.accumulatedRain .. "/" .. rainNeed, x+10, y+60)
end

return PlantRenderer