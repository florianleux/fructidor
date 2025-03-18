-- Composant panneau de score
local ComponentBase = require('src.ui.components.component_base')

local ScorePanel = setmetatable({}, {__index = ComponentBase})
ScorePanel.__index = ScorePanel

function ScorePanel.new(params)
    local self = ComponentBase.new({
        id = "score_panel",
        relX = params.relX or 0,
        relY = params.relY or 0,
        relWidth = params.relWidth or 1,
        relHeight = params.relHeight or 0.15,
        margin = params.margin or {top=10, right=10, bottom=10, left=10},
        scaleManager = params.scaleManager
    })
    
    setmetatable(self, ScorePanel)
    
    -- Référence au gameState pour accéder aux scores
    self.gameState = params.gameState
    
    -- Animation de changement de score
    self.animation = {
        scoreChange = false,
        oldScore = 0,
        newScore = 0,
        time = 0,
        duration = 0.5
    }
    
    return self
end

function ScorePanel:draw()
    if not self.visible or not self.gameState then return end
    
    -- Fond du panneau
    love.graphics.setColor(0.88, 0.92, 0.95)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    love.graphics.setColor(0.7, 0.75, 0.8)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5)
    
    -- Affichage du score actuel
    love.graphics.setColor(0, 0, 0)
    local fontSize = math.min(36, self.height * 0.4)
    love.graphics.setFont(love.graphics.newFont(fontSize))
    
    local score = self.gameState.score
    local objective = self.gameState.objective
    
    -- Si une animation de changement de score est en cours
    if self.animation.scoreChange then
        local progress = self.animation.time / self.animation.duration
        if progress > 1 then progress = 1 end
        
        -- Interpolation entre l'ancien et le nouveau score
        score = math.floor(self.animation.oldScore + 
                (self.animation.newScore - self.animation.oldScore) * progress)
        
        -- Effet visuel pendant le changement
        if progress < 1 then
            love.graphics.setColor(0, 0.6, 0, 0.7 * (1 - progress))
            love.graphics.circle("fill", 
                self.x + self.width * 0.25, 
                self.y + self.height * 0.5, 
                self.height * 0.3 * (1 - progress))
        end
    end
    
    -- Texte du score
    love.graphics.setColor(0, 0, 0)
    local scoreText = "Score: " .. score .. "/" .. objective
    love.graphics.print(scoreText, self.x + 20, self.y + self.height * 0.25)
    
    -- Barre de progression
    local barHeight = self.height * 0.2
    local barY = self.y + self.height * 0.7
    local maxBarWidth = self.width - 40
    
    -- Fond de la barre (gris)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", self.x + 20, barY, maxBarWidth, barHeight)
    
    -- Progression actuelle (vert)
    local progress = math.min(1, score / objective)
    love.graphics.setColor(0.4, 0.8, 0.4)
    love.graphics.rectangle("fill", self.x + 20, barY, maxBarWidth * progress, barHeight)
    
    -- Bordure de la barre
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", self.x + 20, barY, maxBarWidth, barHeight)
    
    -- Affichage des Florins (monnaie du jeu)
    if self.gameState.florins then
        love.graphics.setColor(0, 0, 0)
        local florinText = "Florins: " .. self.gameState.florins
        
        -- Plus petite police pour les florins
        love.graphics.setFont(love.graphics.newFont(fontSize * 0.7))
        love.graphics.print(florinText, self.x + 20, self.y + self.height * 0.05)
    end
end

function ScorePanel:update(dt)
    -- Mise à jour de l'animation de changement de score
    if self.animation.scoreChange then
        self.animation.time = self.animation.time + dt
        if self.animation.time >= self.animation.duration then
            self.animation.scoreChange = false
            self.animation.time = 0
        end
    else if self.gameState and self.gameState.score ~= self.animation.newScore then
            -- Détection d'un changement de score
            self.animation.scoreChange = true
            self.animation.oldScore = self.animation.newScore
            self.animation.newScore = self.gameState.score
            self.animation.time = 0
        end
    end
end

-- Déclenche manuellement une animation de changement de score
function ScorePanel:animateScoreChange(oldScore, newScore)
    self.animation.scoreChange = true
    self.animation.oldScore = oldScore
    self.animation.newScore = newScore
    self.animation.time = 0
end

return ScorePanel
