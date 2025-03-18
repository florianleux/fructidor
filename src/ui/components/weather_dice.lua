-- Composant dés météo
local ComponentBase = require('src.ui.components.component_base')

local WeatherDice = setmetatable({}, {__index = ComponentBase})
WeatherDice.__index = WeatherDice

function WeatherDice.new(params)
    local self = ComponentBase.new({
        id = "weather_dice",
        pixelX = params.pixelX or 576,    -- 30% de 1920
        pixelY = params.pixelY or 108,    -- 10% de 1080
        pixelWidth = params.pixelWidth or 768,  -- 40% de 1920
        pixelHeight = params.pixelHeight or 86,  -- 8% de 1080
        margin = params.margin or {top=5, right=5, bottom=5, left=5},
        scaleManager = params.scaleManager
    })
    
    -- Pour la compatibilité avec l'ancien système
    if params.relX or params.relY or params.relWidth or params.relHeight then
        -- Les valeurs relatives seront converties en pixels dans ComponentBase.new
        self.pixelX = params.relX and math.floor(params.relX * self.scaleManager.referenceWidth) or self.pixelX
        self.pixelY = params.relY and math.floor(params.relY * self.scaleManager.referenceHeight) or self.pixelY
        self.pixelWidth = params.relWidth and math.floor(params.relWidth * self.scaleManager.referenceWidth) or self.pixelWidth
        self.pixelHeight = params.relHeight and math.floor(params.relHeight * self.scaleManager.referenceHeight) or self.pixelHeight
    end
    
    setmetatable(self, WeatherDice)
    
    -- Référence au gameState pour accéder aux valeurs des dés
    self.gameState = params.gameState
    
    -- Animation des dés
    self.animation = {
        rolling = false,
        time = 0,
        duration = 0.5,
        values = {sun = 0, rain = 0}
    }
    
    -- Référence à la fonction pour finir le tour (optionnelle)
    self.endTurnCallback = params.endTurnCallback
    
    return self
end

function WeatherDice:draw()
    if not self.visible or not self.gameState then return end
    
    -- Fond du composant
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Dimensions du dé
    local diceSize = math.min(self.height * 0.8, self.width * 0.15)
    local spacing = self.width * 0.1
    
    -- Position centrale
    local centerX = self.x + self.width / 2
    local centerY = self.y + self.height / 2
    
    -- Dé de soleil
    local sunX = centerX - spacing - diceSize
    local sunY = centerY - diceSize / 2
    
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("fill", sunX, sunY, diceSize, diceSize, 6)
    love.graphics.setColor(0.7, 0.5, 0)
    love.graphics.rectangle("line", sunX, sunY, diceSize, diceSize, 6)
    
    love.graphics.setColor(0, 0, 0)
    local fontSize = diceSize * 0.5
    love.graphics.setFont(love.graphics.newFont(fontSize))
    
    -- Valeur du dé soleil (animée ou finale)
    local sunValue = self.animation.rolling and 
                     math.floor(math.random(1, 6)) or 
                     self.gameState.sunDieValue
    
    love.graphics.print(sunValue, sunX + diceSize/2 - fontSize/4, sunY + diceSize/2 - fontSize/2)
    love.graphics.setFont(love.graphics.newFont(fontSize * 0.6))
    love.graphics.print("Soleil", sunX + diceSize/2 - fontSize/2, sunY + diceSize - fontSize * 0.6)
    
    -- Dé de pluie
    local rainX = centerX + spacing
    local rainY = centerY - diceSize / 2
    
    love.graphics.setColor(0.6, 0.8, 1)
    love.graphics.rectangle("fill", rainX, rainY, diceSize, diceSize, 6)
    love.graphics.setColor(0.4, 0.6, 0.8)
    love.graphics.rectangle("line", rainX, rainY, diceSize, diceSize, 6)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.newFont(fontSize))
    
    -- Valeur du dé pluie (animée ou finale)
    local rainValue = self.animation.rolling and 
                      math.floor(math.random(1, 6)) or 
                      self.gameState.rainDieValue
    
    love.graphics.print(rainValue, rainX + diceSize/2 - fontSize/4, rainY + diceSize/2 - fontSize/2)
    love.graphics.setFont(love.graphics.newFont(fontSize * 0.6))
    love.graphics.print("Pluie", rainX + diceSize/2 - fontSize/2, rainY + diceSize - fontSize * 0.6)
    
    -- Bouton fin de tour
    if self.endTurnCallback then
        local btnWidth = self.width * 0.25
        local btnHeight = self.height * 0.7
        local btnX = self.x + self.width - btnWidth - 10
        local btnY = self.y + (self.height - btnHeight) / 2
        
        -- Mémoriser la position et taille du bouton pour le clic
        self.endTurnButton = {
            x = btnX, y = btnY, 
            width = btnWidth, height = btnHeight
        }
        
        love.graphics.setColor(0.6, 0.8, 0.6)
        love.graphics.rectangle("fill", btnX, btnY, btnWidth, btnHeight, 5)
        love.graphics.setColor(0.5, 0.7, 0.5)
        love.graphics.rectangle("line", btnX, btnY, btnWidth, btnHeight, 5)
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(love.graphics.newFont(fontSize * 0.7))
        local text = "Fin du tour"
        local textWidth = love.graphics.getFont():getWidth(text)
        love.graphics.print(text, btnX + (btnWidth - textWidth)/2, btnY + btnHeight/2 - fontSize/2)
    end
end

function WeatherDice:update(dt)
    -- Animation des dés
    if self.animation.rolling then
        self.animation.time = self.animation.time + dt
        if self.animation.time >= self.animation.duration then
            self.animation.rolling = false
            self.animation.time = 0
        end
    end
end

function WeatherDice:startRolling()
    self.animation.rolling = true
    self.animation.time = 0
end

function WeatherDice:mousepressed(x, y, button)
    if button == 1 and self.endTurnCallback and self.endTurnButton then
        if x >= self.endTurnButton.x and x <= self.endTurnButton.x + self.endTurnButton.width and
           y >= self.endTurnButton.y and y <= self.endTurnButton.y + self.endTurnButton.height then
            -- Lancer l'animation des dés
            self:startRolling()
            -- Appeler le callback de fin de tour
            self.endTurnCallback()
            return true  -- Événement consommé
        end
    end
    return false
end

return WeatherDice
