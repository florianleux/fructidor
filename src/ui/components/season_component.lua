-- Composant unifié d'affichage de saison
-- Suit le modèle d'architecture KISS à deux niveaux
local ComponentBase = require('src.ui.components.component_base')
local Localization = require('src.utils.localization')
local GameConfig = require('src.utils.game_config')

local SeasonComponent = setmetatable({}, {__index = ComponentBase})
SeasonComponent.__index = SeasonComponent

function SeasonComponent.new(params)
    local self = setmetatable(ComponentBase.new(params), SeasonComponent)
    
    -- Modèle associé (gameState)
    self.model = params.gameState
    
    -- Alias pour faciliter la transition du code existant
    self.gameState = self.model
    
    -- Couleurs par saison
    self.seasonColors = {
        [GameConfig.SEASON.SPRING] = {0.7, 0.95, 0.7, 1}, -- Vert clair
        [GameConfig.SEASON.SUMMER] = {1, 0.9, 0.4, 1},    -- Jaune soleil
        [GameConfig.SEASON.AUTUMN] = {0.95, 0.6, 0.3, 1}, -- Orange automne
        [GameConfig.SEASON.WINTER] = {0.8, 0.9, 1, 1}     -- Bleu hiver clair
    }
    
    -- Couleur de texte par saison
    self.textColors = {
        [GameConfig.SEASON.SPRING] = {0.2, 0.5, 0.2, 1},  -- Vert foncé
        [GameConfig.SEASON.SUMMER] = {0.6, 0.4, 0.1, 1},  -- Marron été
        [GameConfig.SEASON.AUTUMN] = {0.5, 0.2, 0.1, 1},  -- Rouge-brun automne
        [GameConfig.SEASON.WINTER] = {0.2, 0.3, 0.6, 1}   -- Bleu hiver foncé
    }
    
    -- Icônes pour chaque saison (optionnel)
    self.seasonIcons = {
        [GameConfig.SEASON.SPRING] = "🌱", -- Pousse
        [GameConfig.SEASON.SUMMER] = "☀️", -- Soleil
        [GameConfig.SEASON.AUTUMN] = "🍂", -- Feuille
        [GameConfig.SEASON.WINTER] = "❄️"  -- Flocon
    }
    
    return self
end

function SeasonComponent:draw()
    if not self.visible then return end
    
    -- Obtenir la couleur de la saison actuelle
    local season = self.gameState.currentSeason
    local backgroundColor = self.seasonColors[season] or {0.9, 0.9, 0.9, 1}
    local textColor = self.textColors[season] or {0.1, 0.1, 0.1, 1}
    
    -- Dessiner le fond de la bannière
    love.graphics.setColor(unpack(backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Dessiner le texte de la saison
    love.graphics.setColor(unpack(textColor))
    
    -- Obtenir le texte de saison localisé
    local seasonText = Localization.getText(season)
    local turnInfo = Localization.getText("ui.tour") .. " " .. self.gameState.currentTurn .. "/8"
    local seasonInfo = Localization.getText("ui.saison_numero") .. " " .. math.ceil(self.gameState.currentTurn/2) .. "/4"
    local seasonIcon = self.seasonIcons[season] or ""
    
    -- Dessiner les informations
    love.graphics.print(seasonIcon .. " " .. seasonText, self.x + 20, self.y + 15, 0, 1.5, 1.5)
    love.graphics.print(turnInfo, self.x + 20, self.y + 45, 0, 1, 1)
    love.graphics.print(seasonInfo, self.x + 150, self.y + 45, 0, 1, 1)
    
    -- Ajouter une bordure décorative
    love.graphics.setColor(textColor[1], textColor[2], textColor[3], 0.5)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5)
    
    -- Dessiner les indicateurs de tour
    self:drawTurnIndicators(textColor)
end

-- Dessiner les indicateurs visuels des tours
function SeasonComponent:drawTurnIndicators(color)
    local totalTurns = 8
    local currentTurn = self.gameState.currentTurn
    local indicatorWidth = (self.width - 40) / totalTurns
    local indicatorHeight = 10
    local indicatorY = self.y + self.height - 20
    
    for i = 1, totalTurns do
        local indicatorX = self.x + 20 + (i-1) * indicatorWidth
        
        if i < currentTurn then
            -- Tour passé
            love.graphics.setColor(color[1], color[2], color[3], 0.8)
            love.graphics.rectangle("fill", indicatorX, indicatorY, indicatorWidth - 2, indicatorHeight, 2)
        elseif i == currentTurn then
            -- Tour actuel
            love.graphics.setColor(color[1], color[2], color[3], 1.0)
            love.graphics.rectangle("fill", indicatorX, indicatorY, indicatorWidth - 2, indicatorHeight, 2)
        else
            -- Tour futur
            love.graphics.setColor(color[1], color[2], color[3], 0.3)
            love.graphics.rectangle("line", indicatorX, indicatorY, indicatorWidth - 2, indicatorHeight, 2)
        end
    end
end

-- Méthode pour les interactions avec la souris (survol sur les indicateurs de tour)
function SeasonComponent:mousemoved(x, y, dx, dy)
    -- On pourrait implémenter un hover sur les indicateurs de tour
    -- pour afficher des informations supplémentaires
    return false
end

-- Méthode explicite pour mettre à jour le composant (pourrait être appelée quand la saison change)
function SeasonComponent:update(dt)
    -- Logique d'animation ou de mise à jour si nécessaire
end

return SeasonComponent