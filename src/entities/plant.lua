-- Entité Plante
local Plant = {}
Plant.__index = Plant

local Constants = require('src.utils.constants')

function Plant.new(family, color)
    local self = setmetatable({}, Plant)
    self.family = family or Constants.PLANT_FAMILY.BRASSIKA
    self.color = color or Constants.COLOR.GREEN
    self.growthStage = Constants.GROWTH_STAGE.SEED
    self.accumulatedSun = 0
    self.accumulatedRain = 0
    
    -- Attributs selon famille
    if self.family == Constants.PLANT_FAMILY.BRASSIKA then
        self.sunToSprout = 3
        self.rainToSprout = 4
        self.sunToFruit = 6
        self.rainToFruit = 8
        self.frostThreshold = -5
        self.baseScore = 20
    elseif self.family == Constants.PLANT_FAMILY.SOLANA then
        self.sunToSprout = 5
        self.rainToSprout = 3
        self.sunToFruit = 10
        self.rainToFruit = 6
        self.frostThreshold = -2
        self.baseScore = 30
    end
    
    return self
end

function Plant:draw(x, y, width, height)
    -- Couleur selon stade de croissance
    if self.growthStage == Constants.GROWTH_STAGE.SEED then
        love.graphics.setColor(0.6, 0.6, 0.4)
    elseif self.growthStage == Constants.GROWTH_STAGE.PLANT then
        love.graphics.setColor(0.4, 0.7, 0.4)
    elseif self.growthStage == Constants.GROWTH_STAGE.FRUITING then
        love.graphics.setColor(0.3, 0.8, 0.3)
    end
    
    -- Dessiner la plante
    love.graphics.rectangle("fill", x+5, y+5, width-10, height-10)
    
    -- Convertir constantes en texte pour affichage
    local familyText = self.family == Constants.PLANT_FAMILY.BRASSIKA and "Brassika" or 
                      (self.family == Constants.PLANT_FAMILY.SOLANA and "Solana" or self.family)
    
    local stageText = self.growthStage == Constants.GROWTH_STAGE.SEED and "Graine" or
                     (self.growthStage == Constants.GROWTH_STAGE.PLANT and "Plant" or
                     (self.growthStage == Constants.GROWTH_STAGE.FRUITING and "Fructifié" or self.growthStage))
    
    -- Afficher infos
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(familyText, x+10, y+15)
    love.graphics.print(stageText, x+10, y+30)
    love.graphics.print("☀️" .. self.accumulatedSun .. "/" .. (self.growthStage == Constants.GROWTH_STAGE.SEED and self.sunToSprout or self.sunToFruit), x+10, y+45)
    love.graphics.print("🌧️" .. self.accumulatedRain .. "/" .. (self.growthStage == Constants.GROWTH_STAGE.SEED and self.rainToSprout or self.rainToFruit), x+10, y+60)
end

function Plant:receiveSun(value)
    self.accumulatedSun = self.accumulatedSun + value
    self:checkGrowth()
end

function Plant:receiveRain(value)
    self.accumulatedRain = self.accumulatedRain + value
    self:checkGrowth()
end

function Plant:checkGrowth()
    if self.growthStage == Constants.GROWTH_STAGE.SEED then
        if self.accumulatedSun >= self.sunToSprout and self.accumulatedRain >= self.rainToSprout then
            self.growthStage = Constants.GROWTH_STAGE.PLANT
            self.accumulatedSun = 0
            self.accumulatedRain = 0
        end
    elseif self.growthStage == Constants.GROWTH_STAGE.PLANT then
        if self.accumulatedSun >= self.sunToFruit and self.accumulatedRain >= self.rainToFruit then
            self.growthStage = Constants.GROWTH_STAGE.FRUITING
        end
    end
end

function Plant:checkFrost(temperature)
    return temperature < self.frostThreshold
end

function Plant:harvest()
    if self.growthStage == Constants.GROWTH_STAGE.FRUITING then
        return self.baseScore
    end
    return 0
end

return Plant