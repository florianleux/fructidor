-- Composant unifié des dés météorologiques
-- Suit le modèle d'architecture KISS à deux niveaux
local ComponentBase = require('src.ui.components.component_base')
local Localization = require('src.utils.localization')
local GameConfig = require('src.utils.game_config')

local WeatherComponent = setmetatable({}, {__index = ComponentBase})
WeatherComponent.__index = WeatherComponent

function WeatherComponent.new(params)
    local self = setmetatable(ComponentBase.new(params), WeatherComponent)
    
    -- Modèle associé (gameState)
    self.model = params.gameState
    
    -- Alias pour faciliter la transition du code existant
    self.gameState = self.model
    
    -- Callback pour la fin du tour
    self.endTurnCallback = params.endTurnCallback
    
    -- Paramètres pour l'animation des dés
    self.diceAnimation = {
        active = false,
        startTime = 0,
        duration = 0.6,  -- Durée réduite pour une animation plus vive
        values = {sun = 0, rain = 0},
        finalValues = {sun = 0, rain = 0},
        seasonRange = {
            sun = {min = -3, max = 8},  -- Plage globale pour toutes les saisons
            rain = {min = 0, max = 6}
        }
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
        buttonBorder = {0.4, 0.6, 0.4},
        negative = {1, 0.3, 0.3}, -- Pour les valeurs négatives
        positive = {0.3, 0.7, 0.3}  -- Pour les valeurs positives
    }
    
    -- État du survol du bouton
    self.buttonHovered = false
    
    return self
end

function WeatherComponent:draw()
    if not self.visible then return end
    
    -- Dessiner le fond
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Calculer les positions des dés
    local centerX = self.x + self.width * 0.5
    local die1X = centerX - self.dieSize - 20
    local die2X = centerX + 20
    local dieY = self.y + (self.height - self.dieSize) * 0.5
    
    -- Dessiner le dé de soleil
    love.graphics.setColor(unpack(self.colors.sunDie))
    love.graphics.rectangle("fill", die1X, dieY, self.dieSize, self.dieSize, self.dieCornerRadius)
    
    -- Dessiner le dé de pluie
    love.graphics.setColor(unpack(self.colors.rainDie))
    love.graphics.rectangle("fill", die2X, dieY, self.dieSize, self.dieSize, self.dieCornerRadius)
    
    -- Dessiner les valeurs des dés
    local sunValue = self.gameState.sunDieValue
    local rainValue = self.gameState.rainDieValue
    
    -- Si une animation est en cours, utiliser les valeurs de l'animation
    if self.diceAnimation.active then
        sunValue = self.diceAnimation.values.sun
        rainValue = self.diceAnimation.values.rain
    end
    
    -- Dessiner les valeurs des dés avec couleur adaptée
    -- Valeur du dé soleil
    if sunValue < 0 then
        love.graphics.setColor(unpack(self.colors.negative))
    else
        love.graphics.setColor(unpack(self.colors.dieText))
    end
    love.graphics.print(tostring(sunValue), die1X + self.dieSize/2 - 10, dieY + self.dieSize/2 - 15, 0, 1.5, 1.5)
    
    -- Label du dé soleil
    love.graphics.setColor(unpack(self.colors.dieText))
    love.graphics.print(Localization.getText("ui.soleil"), die1X + 5, dieY + self.dieSize - 15)
    
    -- Valeur du dé pluie
    love.graphics.setColor(unpack(self.colors.dieText))
    love.graphics.print(tostring(rainValue), die2X + self.dieSize/2 - 10, dieY + self.dieSize/2 - 15, 0, 1.5, 1.5)
    
    -- Label du dé pluie
    love.graphics.print(Localization.getText("ui.pluie"), die2X + 5, dieY + self.dieSize - 15)
    
    -- Dessiner le bouton de fin de tour
    local buttonX = self.x + self.width - self.buttonWidth - 20
    local buttonY = self.y + (self.height - self.buttonHeight) * 0.5
    
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
    local buttonText = Localization.getText("ui.fin_tour")
    local textWidth = love.graphics.getFont():getWidth(buttonText)
    love.graphics.print(buttonText, 
                       buttonX + (self.buttonWidth - textWidth)/2, 
                       buttonY + self.buttonHeight/2 - 10)
    
    -- Dessiner un indicateur de tour actuel/suivant
    self:drawTurnIndicator()
end

-- Méthode pour dessiner l'indicateur du tour actuel/suivant
function WeatherComponent:drawTurnIndicator()
    local indicatorX = self.x + 10
    local indicatorY = self.y + 10
    local indicatorWidth = 80
    local indicatorHeight = 25
    
    love.graphics.setColor(0.7, 0.7, 0.7, 0.5)
    love.graphics.rectangle("fill", indicatorX, indicatorY, indicatorWidth, indicatorHeight, 3)
    
    love.graphics.setColor(0, 0, 0, 0.7)
    local tourText = "Tour: " .. self.gameState.currentTurn .. "/8"
    love.graphics.print(tourText, indicatorX + 5, indicatorY + 5)
end

function WeatherComponent:update(dt)
    -- Mettre à jour l'animation des dés
    self:updateDiceAnimation(dt)
    
    -- Vérifier si la souris survole le bouton
    local mouseX, mouseY = love.mouse.getPosition()
    mouseX = mouseX / (self.scaleManager and self.scaleManager.scale or 1)
    mouseY = mouseY / (self.scaleManager and self.scaleManager.scale or 1)
    
    -- Calculer la position du bouton
    local buttonX = self.x + self.width - self.buttonWidth - 20
    local buttonY = self.y + (self.height - self.buttonHeight) * 0.5
    
    -- Vérifier si la souris survole le bouton
    self.buttonHovered = (mouseX >= buttonX and mouseX <= buttonX + self.buttonWidth and
                          mouseY >= buttonY and mouseY <= buttonY + self.buttonHeight)
end

-- Méthode pour l'animation des dés
function WeatherComponent:updateDiceAnimation(dt)
    if not self.diceAnimation.active then return end
    
    local elapsed = love.timer.getTime() - self.diceAnimation.startTime
    local progress = math.min(1, elapsed / self.diceAnimation.duration)
    
    -- Animation en trois phases simples
    if progress < 0.7 then
        -- Phase 1 et 2: Valeurs aléatoires avec fréquence réduite progressivement
        local changeFrequency = 0.3 - (progress * 0.3) -- Diminue de 0.3 à 0.0
        
        -- Changer les valeurs aléatoirement avec une fréquence qui diminue
        if math.random() < changeFrequency then
            -- Valeurs aléatoires dans les plages définies
            self.diceAnimation.values.sun = math.random(
                self.diceAnimation.seasonRange.sun.min, 
                self.diceAnimation.seasonRange.sun.max
            )
            self.diceAnimation.values.rain = math.random(
                self.diceAnimation.seasonRange.rain.min, 
                self.diceAnimation.seasonRange.rain.max
            )
        end
    else
        -- Phase 3: Montrer les valeurs finales
        self.diceAnimation.values.sun = self.diceAnimation.finalValues.sun
        self.diceAnimation.values.rain = self.diceAnimation.finalValues.rain
    end
    
    -- Fin de l'animation
    if progress >= 1 then
        self.diceAnimation.active = false
    end
end

function WeatherComponent:mousepressed(x, y, button)
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

function WeatherComponent:startRolling()
    -- Configurer la plage de valeurs pour cette saison
    local seasonData = GameConfig.DICE_RANGES[self.gameState.currentSeason]
    if seasonData then
        self.diceAnimation.seasonRange = {
            sun = seasonData.sun,
            rain = seasonData.rain
        }
    end
    
    -- Configuration de l'animation
    self.diceAnimation.active = true
    self.diceAnimation.startTime = love.timer.getTime()
    
    -- Stocker les valeurs finales des dés
    self.diceAnimation.finalValues = {
        sun = self.gameState.sunDieValue,
        rain = self.gameState.rainDieValue
    }
    
    -- Initialiser les valeurs temporaires avec des valeurs aléatoires dans la plage
    self.diceAnimation.values = {
        sun = math.random(self.diceAnimation.seasonRange.sun.min, self.diceAnimation.seasonRange.sun.max),
        rain = math.random(self.diceAnimation.seasonRange.rain.min, self.diceAnimation.seasonRange.rain.max)
    }
end

-- Méthode de rafraichissement (appelée quand les dés changent)
function WeatherComponent:refreshDice()
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

return WeatherComponent