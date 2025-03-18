-- Composant d'affichage des dés météorologiques et du bouton de fin de tour
local ComponentBase = require('src.ui.components.component_base')
local Localization = require('src.utils.localization')

local WeatherDice = setmetatable({}, {__index = ComponentBase})
WeatherDice.__index = WeatherDice

function WeatherDice.new(params)
    local self = setmetatable(ComponentBase.new(params), WeatherDice)
    
    -- Paramètres spécifiques aux dés météo
    self.gameState = params.gameState
    self.endTurnCallback = params.endTurnCallback
    
    -- Paramètres pour l'animation des dés
    self.diceAnimation = {
        active = false,
        startTime = 0,
        duration = 0.8,
        values = {}, -- Valeurs temporaires pendant l'animation
        finalValues = {} -- Valeurs finales à atteindre
    }
    
    -- Dimensions visuelles
    self.dieSize = 60
    self.dieCornerRadius = 8
    self.buttonWidth = 120
    self.buttonHeight = 40
    
    -- Couleurs
    self.colors = {
        background = {0.8, 0.9, 0.95, 1},
        sunDie = {1, 0.8, 0},
        rainDie = {0.6, 0.8, 1},
        dieText = {0, 0, 0},
        buttonBackground = {0.6, 0.8, 0.6},
        buttonHover = {0.7, 0.9, 0.7},
        buttonText = {0, 0, 0},
        buttonBorder = {0.4, 0.6, 0.4}
    }
    
    -- État du survol du bouton
    self.buttonHovered = false
    
    return self
end

function WeatherDice:draw()
    -- Convertir les coordonnées pixel en coordonnées d'écran
    local x, y, width, height = self:getScaledBounds()
    
    -- Dessiner le fond
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", x, y, width, height, 5)
    
    -- Calculer les positions des dés
    local centerX = x + width * 0.5
    local die1X = centerX - self.dieSize - 20
    local die2X = centerX + 20
    local dieY = y + (height - self.dieSize) * 0.5
    
    -- Dessiner le dé de soleil
    love.graphics.setColor(unpack(self.colors.sunDie))
    love.graphics.rectangle("fill", die1X, dieY, self.dieSize, self.dieSize, self.dieCornerRadius)
    
    -- Dessiner le dé de pluie
    love.graphics.setColor(unpack(self.colors.rainDie))
    love.graphics.rectangle("fill", die2X, dieY, self.dieSize, self.dieSize, self.dieCornerRadius)
    
    -- Dessiner les valeurs des dés
    love.graphics.setColor(unpack(self.colors.dieText))
    local sunValue = self.gameState.sunDieValue
    local rainValue = self.gameState.rainDieValue
    
    -- Si une animation est en cours, utiliser les valeurs de l'animation
    if self.diceAnimation.active then
        sunValue = self.diceAnimation.values.sun
        rainValue = self.diceAnimation.values.rain
    end
    
    -- Dessiner les valeurs et labels des dés
    love.graphics.print(tostring(sunValue), die1X + self.dieSize/2 - 10, dieY + self.dieSize/2 - 15, 0, 1.5, 1.5)
    love.graphics.print(Localization.getText("ui.soleil"), die1X + 5, dieY + self.dieSize - 15)
    
    love.graphics.print(tostring(rainValue), die2X + self.dieSize/2 - 10, dieY + self.dieSize/2 - 15, 0, 1.5, 1.5)
    love.graphics.print(Localization.getText("ui.pluie"), die2X + 5, dieY + self.dieSize - 15)
    
    -- Dessiner le bouton de fin de tour
    local buttonX = x + width - self.buttonWidth - 20
    local buttonY = y + (height - self.buttonHeight) * 0.5
    
    -- Couleur du bouton (normale ou survol)
    if self.buttonHovered then
        love.graphics.setColor(unpack(self.colors.buttonHover))
    else
        love.graphics.setColor(unpack(self.colors.buttonBackground))
    end
    
    -- Dessiner le bouton
    love.graphics.rectangle("fill", buttonX, buttonY, self.buttonWidth, self.buttonHeight, 5)
    
    -- Bordure du bouton
    love.graphics.setColor(unpack(self.colors.buttonBorder))
    love.graphics.rectangle("line", buttonX, buttonY, self.buttonWidth, self.buttonHeight, 5)
    
    -- Texte du bouton
    love.graphics.setColor(unpack(self.colors.buttonText))
    love.graphics.print(Localization.getText("ui.fin_tour"), 
                        buttonX + self.buttonWidth/2 - 30, 
                        buttonY + self.buttonHeight/2 - 10)
end

function WeatherDice:update(dt)
    -- Mettre à jour l'animation des dés si elle est active
    if self.diceAnimation.active then
        local elapsed = love.timer.getTime() - self.diceAnimation.startTime
        local progress = math.min(1, elapsed / self.diceAnimation.duration)
        
        -- Interpolation avec ease-out (rebond)
        local ease = math.sin(progress * math.pi / 2)
        
        -- Générer des valeurs aléatoires pendant l'animation
        if progress < 0.7 then
            -- Phase de roulement rapide
            local speed = 10 - progress * 10 -- Ralentit progressivement
            if math.random() < dt * speed then
                -- Valeurs aléatoires pendant l'animation
                self.diceAnimation.values.sun = math.random(-3, 8)
                self.diceAnimation.values.rain = math.random(0, 6)
            end
        else
            -- Phase finale - convergence vers les valeurs finales
            local finalProgress = (progress - 0.7) / 0.3
            self.diceAnimation.values.sun = math.floor(self.diceAnimation.finalValues.sun + 0.5)
            self.diceAnimation.values.rain = math.floor(self.diceAnimation.finalValues.rain + 0.5)
        end
        
        -- Fin de l'animation
        if progress >= 1 then
            self.diceAnimation.active = false
            self.diceAnimation.values.sun = self.diceAnimation.finalValues.sun
            self.diceAnimation.values.rain = self.diceAnimation.finalValues.rain
        end
    end
    
    -- Vérifier si la souris survole le bouton
    local mouseX, mouseY = love.mouse.getPosition()
    mouseX = mouseX / (self.scaleManager.scale or 1)
    mouseY = mouseY / (self.scaleManager.scale or 1)
    
    -- Calculer la position du bouton
    local x, y, width, height = self:getScaledBounds()
    local buttonX = x + width - self.buttonWidth - 20
    local buttonY = y + (height - self.buttonHeight) * 0.5
    
    -- Vérifier si la souris survole le bouton
    self.buttonHovered = (mouseX >= buttonX and mouseX <= buttonX + self.buttonWidth and
                           mouseY >= buttonY and mouseY <= buttonY + self.buttonHeight)
end

function WeatherDice:mousepressed(x, y, button)
    -- Vérifier si le clic est sur le bouton de fin de tour
    if button == 1 and self.buttonHovered then
        -- Appeler la fonction de callback de fin de tour
        if self.endTurnCallback then
            self.endTurnCallback()
            -- Commencer l'animation des dés après le changement de tour
            self:startRolling()
        end
        return true -- Le clic a été traité
    end
    return false -- Le clic n'a pas été traité
end

function WeatherDice:startRolling()
    -- Configuration de l'animation
    self.diceAnimation.active = true
    self.diceAnimation.startTime = love.timer.getTime()
    
    -- Stocker les valeurs finales des dés
    self.diceAnimation.finalValues = {
        sun = self.gameState.sunDieValue,
        rain = self.gameState.rainDieValue
    }
    
    -- Initialiser les valeurs temporaires
    self.diceAnimation.values = {
        sun = math.random(-3, 8),
        rain = math.random(0, 6)
    }
end

function WeatherDice:updateDice()
    -- Cette méthode est appelée pour mettre à jour les dés 
    -- lorsque les valeurs changent dans le GameState
    
    -- Si les dés ne sont pas en animation, les mettre à jour immédiatement
    if not self.diceAnimation.active then
        self:startRolling()
    else
        -- Sinon, mettre à jour les valeurs finales
        self.diceAnimation.finalValues = {
            sun = self.gameState.sunDieValue,
            rain = self.gameState.rainDieValue
        }
    end
end

return WeatherDice