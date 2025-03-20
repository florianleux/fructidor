-- Composant unifié d'affichage de saison
local ComponentBase = require('src.ui.components.component_base')
local Localization = require('src.utils.localization')
local GameConfig = require('src.utils.game_config')

local SeasonComponent = {}
SeasonComponent.__index = SeasonComponent

function SeasonComponent.new(params)
    local self = {}
    setmetatable(self, SeasonComponent)
    
    -- Attributs de base (copier explicitement ComponentBase)
    self.x = params.x or 0
    self.y = params.y or 0
    self.width = params.width or 100
    self.height = params.height or 100
    self.visible = params.visible ~= false
    self.id = params.id or "season"
    self.scaleManager = params.scaleManager
    
    -- Référence directe au gameState
    self.gameState = params.model or params.gameState
    
    -- Initialisation d'un gameState par défaut si nécessaire
    if not self.gameState then
        self.gameState = {
            currentSeason = GameConfig.SEASON.SPRING,
            currentTurn = 1
        }
    end
    
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
        [GameConfig.SEASON.SPRING] = "\240\159\140\ 177", -- Pousse
        [GameConfig.SEASON.SUMMER] = "\226\152\128\239\184\143", -- Soleil
        [GameConfig.SEASON.AUTUMN] = "\240\159\141\130", -- Feuille
        [GameConfig.SEASON.WINTER] = "\226\157\132\239\184\143"  -- Flocon
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

-- Méthode pour les interactions avec la souris
function SeasonComponent:mousemoved(x, y, dx, dy)
    -- On pourrait implémenter un hover sur les indicateurs de tour
    -- pour afficher des informations supplémentaires
    return false
end

-- Méthode explicite pour mettre à jour le composant
function SeasonComponent:refreshSeason()
    -- Méthode appelée quand la saison change
    -- Pas besoin d'implémentation spécifique car nous lisons directement le gameState
    print("SeasonComponent:refreshSeason - Saison mise à jour")
end

-- Implémentation des méthodes de ComponentBase
function SeasonComponent:containsPoint(x, y)
    return self.visible and 
           x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function SeasonComponent:getBounds()
    return self.x, self.y, self.width, self.height
end

function SeasonComponent:update(dt)
    -- Rien à mettre à jour
end

function SeasonComponent:mousereleased(x, y, button)
    return false
end

return SeasonComponent