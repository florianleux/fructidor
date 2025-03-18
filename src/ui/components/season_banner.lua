-- Bannière d'affichage de la saison actuelle
local ComponentBase = require('src.ui.components.component_base')
local Localization = require('src.utils.localization')
local Constants = require('src.utils.constants')

local SeasonBanner = setmetatable({}, {__index = ComponentBase})
SeasonBanner.__index = SeasonBanner

function SeasonBanner.new(params)
    local self = setmetatable(ComponentBase.new(params), SeasonBanner)
    
    -- Paramètres spécifiques à la bannière de saison
    self.gameState = params.gameState
    
    -- Couleurs par saison
    self.seasonColors = {
        [Constants.SEASON.SPRING] = {0.7, 0.95, 0.7, 1}, -- Vert clair
        [Constants.SEASON.SUMMER] = {1, 0.9, 0.4, 1},    -- Jaune soleil
        [Constants.SEASON.AUTUMN] = {0.95, 0.6, 0.3, 1}, -- Orange automne
        [Constants.SEASON.WINTER] = {0.8, 0.9, 1, 1}     -- Bleu hiver clair
    }
    
    -- Couleur de texte par saison
    self.textColors = {
        [Constants.SEASON.SPRING] = {0.2, 0.5, 0.2, 1},  -- Vert foncé
        [Constants.SEASON.SUMMER] = {0.6, 0.4, 0.1, 1},  -- Marron été
        [Constants.SEASON.AUTUMN] = {0.5, 0.2, 0.1, 1},  -- Rouge-brun automne
        [Constants.SEASON.WINTER] = {0.2, 0.3, 0.6, 1}   -- Bleu hiver foncé
    }
    
    return self
end

function SeasonBanner:draw()
    -- Convertir les coordonnées pixel en coordonnées d'écran
    local x, y, width, height = self:getScaledBounds()
    
    -- Obtenir la couleur de la saison actuelle
    local season = self.gameState.currentSeason
    local backgroundColor = self.seasonColors[season] or {0.9, 0.9, 0.9, 1}
    local textColor = self.textColors[season] or {0.1, 0.1, 0.1, 1}
    
    -- Dessiner le fond de la bannière
    love.graphics.setColor(unpack(backgroundColor))
    love.graphics.rectangle("fill", x, y, width, height, 5)
    
    -- Dessiner le texte de la saison
    love.graphics.setColor(unpack(textColor))
    
    -- Obtenir le texte de saison localisé
    local seasonText = Localization.getText(season)
    local turnInfo = Localization.getText("ui.tour") .. " " .. self.gameState.currentTurn .. "/8"
    local seasonInfo = Localization.getText("ui.saison_numero") .. " " .. math.ceil(self.gameState.currentTurn/2) .. "/4"
    
    -- Dessiner les informations
    love.graphics.print(seasonText, x + 20, y + 15, 0, 1.5, 1.5)
    love.graphics.print(turnInfo, x + 20, y + 45, 0, 1, 1)
    love.graphics.print(seasonInfo, x + 150, y + 45, 0, 1, 1)
    
    -- Ajouter une bordure décorative
    love.graphics.setColor(textColor[1], textColor[2], textColor[3], 0.5)
    love.graphics.rectangle("line", x, y, width, height, 5)
end

function SeasonBanner:updateSeason()
    -- Cette méthode est appelée pour mettre à jour la bannière 
    -- lorsque la saison change dans le GameState
    -- Pour l'instant, il suffit de laisser le système de dessin récupérer 
    -- la saison directement depuis gameState à chaque frame
end

return SeasonBanner