-- Entité Plante
local Plant = {}
Plant.__index = Plant

function Plant.new(family, color)
    local self = setmetatable({}, Plant)
    self.family = family or "Brassika"
    self.color = color or "Vert"
    self.growthStage = "Graine"  -- Graine, Plant, Fructifié
    self.accumulatedSun = 0
    self.accumulatedRain = 0
    
    -- Attributs selon famille
    if self.family == "Brassika" then
        self.sunToSprout = 3
        self.rainToSprout = 4
        self.sunToFruit = 6
        self.rainToFruit = 8
        self.frostThreshold = -5
        self.baseScore = 20
    elseif self.family == "Solana" then
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
    if self.growthStage == "Graine" then
        love.graphics.setColor(0.6, 0.6, 0.4)
    elseif self.growthStage == "Plant" then
        love.graphics.setColor(0.4, 0.7, 0.4)
    elseif self.growthStage == "Fructifié" then
        love.graphics.setColor(0.3, 0.8, 0.3)
    end
    
    -- Dessiner la plante
    love.graphics.rectangle("fill", x+5, y+5, width-10, height-10)
    
    -- Afficher infos
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.family, x+10, y+15)
    love.graphics.print(self.growthStage, x+10, y+30)
    love.graphics.print("☀️" .. self.accumulatedSun .. "/" .. (self.growthStage == "Graine" and self.sunToSprout or self.sunToFruit), x+10, y+45)
    love.graphics.print("🌧️" .. self.accumulatedRain .. "/" .. (self.growthStage == "Graine" and self.rainToSprout or self.rainToFruit), x+10, y+60)
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
    if self.growthStage == "Graine" then
        if self.accumulatedSun >= self.sunToSprout and self.accumulatedRain >= self.rainToSprout then
            self.growthStage = "Plant"
            self.accumulatedSun = 0
            self.accumulatedRain = 0
        end
    elseif self.growthStage == "Plant" then
        if self.accumulatedSun >= self.sunToFruit and self.accumulatedRain >= self.rainToFruit then
            self.growthStage = "Fructifié"
        end
    end
end

function Plant:checkFrost(temperature)
    return temperature < self.frostThreshold
end

function Plant:harvest()
    if self.growthStage == "Fructifié" then
        return self.baseScore
    end
    return 0
end

return Plant
