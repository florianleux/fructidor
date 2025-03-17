-- Configuration du jeu
local Constants = require('src.utils.constants')

return {
    -- Paramètres généraux
    baseTurnsPerLevel = 8,
    seasonsPerLevel = 4,
    turnsPerSeason = 2,
    
    -- Plages de dés par saison
    diceRanges = {
        [Constants.SEASON.SPRING] = {
            sun = {min = -1, max = 5},
            rain = {min = 2, max = 6}
        },
        [Constants.SEASON.SUMMER] = {
            sun = {min = 3, max = 8},
            rain = {min = 0, max = 4}
        },
        [Constants.SEASON.AUTUMN] = {
            sun = {min = -2, max = 4},
            rain = {min = 1, max = 6}
        },
        [Constants.SEASON.WINTER] = {
            sun = {min = -3, max = 2},
            rain = {min = 0, max = 4}
        }
    },
    
    -- Objectifs et récompenses
    baseScoreObjective = 100,
    
    -- Paramètres jeu
    initialDeckSize = 15,
    initialHandSize = 5,
    initialGardenSize = {width = 3, height = 2},
    
    -- Propriétés plantes
    plantConfigs = {
        [Constants.PLANT_FAMILY.BRASSIKA] = {
            frostThreshold = -5,
            sunToSprout = 3,
            rainToSprout = 4,
            sunToFruit = 6,
            rainToFruit = 8,
            baseScore = 20
        },
        [Constants.PLANT_FAMILY.SOLANA] = {
            frostThreshold = -2,
            sunToSprout = 5,
            rainToSprout = 3,
            sunToFruit = 10,
            rainToFruit = 6,
            baseScore = 30
        }
    }
}