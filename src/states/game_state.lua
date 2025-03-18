-- État principal du jeu
local Garden = require('src.entities.garden')
local Constants = require('src.utils.constants')
local Config = require('src.utils.config')
local DependencyContainer = require('src.utils.dependency_container')
local Localization = require('src.utils.localization')

local GameState = {}
GameState.__index = GameState

-- Constructeur modifié pour accepter les dépendances
function GameState.new(dependencies)
    local self = setmetatable({}, GameState)
    
    -- Stocker les dépendances
    self.dependencies = dependencies or {}
    self.scaleManager = self.dependencies.scaleManager
    
    -- Créer un jardin ou utiliser celui fourni
    self.garden = self.dependencies.garden or Garden.new(3, 2) -- Grille 3x2 pour l'Alpha
    
    self.currentTurn = 1
    self.maxTurns = 8
    self.currentSeason = Constants.SEASON.SPRING
    self.sunDieValue = 0  -- Sera initialisé par rollDice
    self.rainDieValue = 0 -- Sera initialisé par rollDice
    self.score = 0
    self.objective = 100
    self.florins = 0 -- Ajout de la monnaie du jeu
    
    -- Initialiser les dés pour le premier tour
    self:rollDice()
    
    return self
end

function GameState:update(dt)
    -- Mise à jour logique
    -- Note: Cette méthode reste minimale car la plupart des mises à jour 
    -- sont conduites par les événements ou les actions du joueur
end

-- La méthode draw a été supprimée car le dessin est maintenant géré par les composants UI

function GameState:mousepressed(x, y, button)
    -- Cette méthode est conservée pour la compatibilité, mais elle est maintenant vide
    -- car les interactions souris sont gérées par les composants UI
    return false
end

function GameState:mousereleased(x, y, button)
    -- Cette méthode est conservée pour la compatibilité, mais elle est maintenant vide
    -- car les interactions souris sont gérées par les composants UI
    return false
end

function GameState:rollDice()
    -- Utiliser directement les constantes pour accéder aux plages de dés
    local seasonData = Config.diceRanges[self.currentSeason]
    
    -- Lancer les dés avec les plages de la saison
    self.sunDieValue = math.random(seasonData.sun.min, seasonData.sun.max)
    self.rainDieValue = math.random(seasonData.rain.min, seasonData.rain.max)
    
    -- Appliquer les effets météo à toutes les plantes
    self:applyWeather()
end

function GameState:applyWeather()
    for y = 1, self.garden.height do
        for x = 1, self.garden.width do
            local cell = self.garden.grid[y][x]
            if cell.plant then
                -- Appliquer effets soleil et pluie
                if self.sunDieValue > 0 then
                    cell.plant:receiveSun(self.sunDieValue)
                end
                
                if self.rainDieValue > 0 then
                    cell.plant:receiveRain(self.rainDieValue)
                end
                
                -- Vérifier gel si température négative
                if self.sunDieValue < 0 and cell.plant:checkFrost(self.sunDieValue) then
                    -- La plante gèle et meurt
                    self.garden.grid[y][x].plant = nil
                    self.garden.grid[y][x].state = Constants.CELL_STATE.EMPTY
                end
            end
        end
    end
end

function GameState:nextTurn()
    -- Récupérer le système de cartes via les dépendances ou le conteneur
    local cardSystem = self.dependencies.cardSystem or DependencyContainer.tryResolve("CardSystem")
    
    -- Piocher une carte
    if cardSystem then
        cardSystem:drawCard()
    end
    
    -- Passer au tour suivant
    self.currentTurn = self.currentTurn + 1
    
    -- Vérifier fin de partie
    if self.currentTurn > self.maxTurns then
        self.currentTurn = 1
    end
    
    -- Mettre à jour la saison
    local season = math.ceil(self.currentTurn / 2)
    if season == 1 then
        self.currentSeason = Constants.SEASON.SPRING
    elseif season == 2 then
        self.currentSeason = Constants.SEASON.SUMMER
    elseif season == 3 then
        self.currentSeason = Constants.SEASON.AUTUMN
    elseif season == 4 then
        self.currentSeason = Constants.SEASON.WINTER
    end
    
    -- Lancer les dés pour ce tour
    self:rollDice()
end

-- Méthode pour ajouter des points au score
function GameState:addScore(points)
    local oldScore = self.score
    self.score = self.score + points
    
    -- Retourner le delta pour permettre des animations
    return self.score - oldScore
end

-- Méthode pour ajouter des florins
function GameState:addFlorins(amount)
    self.florins = self.florins + amount
    return amount
end

-- Méthode pour tenter d'acheter quelque chose
function GameState:spendFlorins(amount)
    if self.florins >= amount then
        self.florins = self.florins - amount
        return true
    end
    return false
end

return GameState