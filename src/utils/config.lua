-- Configuration du jeu
return {
    -- Paramètres généraux
    baseTurnsPerLevel = 8,
    seasonsPerLevel = 4,
    turnsPerSeason = 2,
    
    -- Plages de dés par saison
    diceRanges = {
        spring = {
            sun = {min = -1, max = 5},
            rain = {min = 2, max = 6}
        },
        summer = {
            sun = {min = 3, max = 8},
            rain = {min = 0, max = 4}
        },
        autumn = {
            sun = {min = -2, max = 4},
            rain = {min = 1, max = 6}
        },
        winter = {
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
        Brassika = {
            frostThreshold = -5,
            sunToSprout = 3,
            rainToSprout = 4,
            sunToFruit = 6,
            rainToFruit = 8,
            baseScore = 20
        },
        Solana = {
            frostThreshold = -2,
            sunToSprout = 5,
            rainToSprout = 3,
            sunToFruit = 10,
            rainToFruit = 6,
            baseScore = 30
        }
    }
}
