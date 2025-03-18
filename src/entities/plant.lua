-- Entité Plante
local GameConfig = require('src.utils.game_config')

local Plant = {}
Plant.__index = Plant

function Plant.new(family, color, posX, posY)
    local self = setmetatable({}, Plant)
    self.family = family or GameConfig.PLANT_FAMILY.BRASSIKA
    self.color = color or GameConfig.COLOR.GREEN
    self.growthStage = GameConfig.GROWTH_STAGE.SEED
    self.accumulatedSun = 0
    self.accumulatedRain = 0
    self.posX = posX or nil
    self.posY = posY or nil
    
    -- Attributs selon famille
    if self.family == GameConfig.PLANT_FAMILY.BRASSIKA then
        self.sunToSprout = 3
        self.rainToSprout = 4
        self.sunToFruit = 6
        self.rainToFruit = 8
        self.frostThreshold = -5
        self.baseScore = 20
    elseif self.family == GameConfig.PLANT_FAMILY.SOLANA then
        self.sunToSprout = 5
        self.rainToSprout = 3
        self.sunToFruit = 10
        self.rainToFruit = 6
        self.frostThreshold = -2
        self.baseScore = 30
    end
    
    return self
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
    if self.growthStage == GameConfig.GROWTH_STAGE.SEED then
        if self.accumulatedSun >= self.sunToSprout and self.accumulatedRain >= self.rainToSprout then
            self.growthStage = GameConfig.GROWTH_STAGE.SPROUT
            self.accumulatedSun = 0
            self.accumulatedRain = 0
        end
    elseif self.growthStage == GameConfig.GROWTH_STAGE.SPROUT then
        if self.accumulatedSun >= self.sunToFruit and self.accumulatedRain >= self.rainToFruit then
            self.growthStage = GameConfig.GROWTH_STAGE.FRUIT
        end
    end
end

function Plant:checkFrost(temperature)
    return temperature < self.frostThreshold
end

function Plant:harvest()
    if self.growthStage == GameConfig.GROWTH_STAGE.FRUIT then
        return self.baseScore
    end
    return 0
end

return Plant