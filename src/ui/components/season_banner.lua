-- Composant bannière de saison
local ComponentBase = require('src.ui.components.component_base')

local SeasonBanner = setmetatable({}, {__index = ComponentBase})
SeasonBanner.__index = SeasonBanner

function SeasonBanner.new(params)
    local self = ComponentBase.new({
        id = "season_banner",
        relX = params.relX or 0,
        relY = params.relY or 0,
        relWidth = params.relWidth or 1,
        relHeight = params.relHeight or 0.05,
        margin = params.margin or {top=10, right=10, bottom=0, left=10},
        scaleManager = params.scaleManager
    })
    
    setmetatable(self, SeasonBanner)
    
    -- Couleurs spécifiques par saison
    self.seasonColors = {
        Printemps = {0.7, 0.9, 0.7},  -- Vert clair
        Été = {0.9, 0.9, 0.5},        -- Jaune
        Automne = {0.9, 0.7, 0.5},    -- Orange
        Hiver = {0.8, 0.9, 1.0}       -- Bleu clair
    }
    
    -- Référence au gameState pour accéder aux données de saison et tour
    self.gameState = params.gameState
    
    return self
end

function SeasonBanner:draw()
    if not self.visible or not self.gameState then return end
    
    -- Couleur de fond selon la saison
    local bgColor = self.seasonColors[self.gameState.currentSeason] or {0.9, 0.95, 0.9}
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Bordure
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5)
    
    -- Texte de la saison
    love.graphics.setColor(0, 0, 0)
    
    -- Texte centré verticalement
    local fontSize = 24
    local textY = self.y + (self.height - fontSize) / 2
    
    -- Adapter la taille du texte en fonction de la largeur disponible
    local seasonText = "Saison: " .. self.gameState.currentSeason .. 
                      " (" .. math.ceil(self.gameState.currentTurn/2) .. "/4)"
    
    love.graphics.setFont(love.graphics.newFont(fontSize))
    love.graphics.print(seasonText, self.x + 20, textY)
end

function SeasonBanner:update(dt)
    -- Pas d'animation ou de logique spécifique pour le moment
end

return SeasonBanner
