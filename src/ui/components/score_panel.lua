-- Panneau d'affichage du score
local ComponentBase = require('src.ui.components.component_base')
local Localization = require('src.utils.localization')

local ScorePanel = setmetatable({}, {__index = ComponentBase})
ScorePanel.__index = ScorePanel

function ScorePanel.new(params)
    local self = setmetatable(ComponentBase.new(params), ScorePanel)
    
    -- Paramètres spécifiques au panneau de score
    self.gameState = params.gameState
    
    -- Variables d'animation
    self.scoreAnimation = {
        active = false,
        previousValue = self.gameState.score,
        currentValue = self.gameState.score,
        startTime = 0,
        duration = 0.5
    }
    
    -- Couleurs
    self.colors = {
        background = {0.9, 0.92, 0.95, 1},
        text = {0.1, 0.1, 0.1, 1},
        progressBg = {0.8, 0.8, 0.8, 1},
        progressFill = {0.5, 0.8, 0.5, 1},
        progressText = {0.1, 0.1, 0.1, 1},
        valorant = {0.3, 0.5, 0.9, 1},
        florins = {0.9, 0.8, 0.2, 1}
    }
    
    return self
end

function ScorePanel:draw()
    -- Convertir les coordonnées pixel en coordonnées d'écran
    local x, y, width, height = self:getScaledBounds()
    
    -- Dessiner le fond du panneau
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", x, y, width, height, 5)
    
    -- Dessiner le titre du panneau
    love.graphics.setColor(unpack(self.colors.text))
    local titleY = y + 15
    love.graphics.print(Localization.getText("ui.score_title"), x + 20, titleY, 0, 1.2, 1.2)
    
    -- Dessiner le score actuel et l'objectif
    local scoreText
    if self.scoreAnimation.active then
        scoreText = math.floor(self.scoreAnimation.currentValue)
    else
        scoreText = self.gameState.score
    end
    
    local scoreStr = scoreText .. "/" .. self.gameState.objective
    local scoreY = titleY + 30
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.print(Localization.getText("ui.score") .. ": " .. scoreStr, x + 20, scoreY, 0, 1, 1)
    
    -- Dessiner la barre de progression
    local progressY = scoreY + 30
    local progressWidth = width - 40
    local progressHeight = 12
    
    -- Fond de la barre
    love.graphics.setColor(unpack(self.colors.progressBg))
    love.graphics.rectangle("fill", x + 20, progressY, progressWidth, progressHeight, 3)
    
    -- Remplissage de la barre
    local fillRatio
    if self.scoreAnimation.active then
        fillRatio = self.scoreAnimation.currentValue / self.gameState.objective
    else
        fillRatio = self.gameState.score / self.gameState.objective
    end
    fillRatio = math.min(1, math.max(0, fillRatio)) -- Entre 0 et 1
    
    love.graphics.setColor(unpack(self.colors.progressFill))
    love.graphics.rectangle("fill", x + 20, progressY, progressWidth * fillRatio, progressHeight, 3)
    
    -- Afficher les Florins
    local florinsY = progressY + 30
    love.graphics.setColor(unpack(self.colors.florins))
    love.graphics.print(Localization.getText("ui.florins") .. ": " .. (self.gameState.florins or 0), x + 20, florinsY, 0, 1, 1)
end

function ScorePanel:update(dt)
    -- Mettre à jour l'animation du score si elle est active
    if self.scoreAnimation.active then
        local elapsed = love.timer.getTime() - self.scoreAnimation.startTime
        local progress = math.min(1, elapsed / self.scoreAnimation.duration)
        
        -- Interpolation avec ease-out (ralentit à la fin)
        local ease = 1 - (1 - progress) * (1 - progress)
        
        -- Mettre à jour la valeur courante
        self.scoreAnimation.currentValue = self.scoreAnimation.previousValue + 
            (self.gameState.score - self.scoreAnimation.previousValue) * ease
        
        -- Fin de l'animation
        if progress >= 1 then
            self.scoreAnimation.active = false
            self.scoreAnimation.currentValue = self.gameState.score
        end
    end
end

function ScorePanel:updateScore()
    -- Méthode appelée lorsque le score change
    -- Si le score a changé depuis la dernière mise à jour, démarrer une animation
    if not self.scoreAnimation.active and self.scoreAnimation.currentValue ~= self.gameState.score then
        self:animateScoreChange(self.scoreAnimation.currentValue)
    end
end

function ScorePanel:animateScoreChange(previousScore)
    -- Si aucun score précédent n'est fourni, utiliser le score actuel
    previousScore = previousScore or self.scoreAnimation.currentValue
    
    -- Configurer l'animation
    self.scoreAnimation.active = true
    self.scoreAnimation.previousValue = previousScore
    self.scoreAnimation.startTime = love.timer.getTime()
    
    -- Si l'animation est déjà en cours, continuer à partir de la valeur actuelle
    if self.scoreAnimation.active then
        self.scoreAnimation.previousValue = self.scoreAnimation.currentValue
    end
end

return ScorePanel