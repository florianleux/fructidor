-- src/utils/config.lua
-- COMPATIBILITÉ: Ce module est maintenu pour la rétrocompatibilité et redirige vers game_config.lua

local GameConfig = require('src.utils.game_config')

-- Message avertissant de la dépréciation
print("AVERTISSEMENT: Le module 'config.lua' est déprécié. Utilisez 'game_config.lua' à la place.")

-- Créer une structure qui imite l'ancien format de config
return {
    -- Paramètres généraux
    baseTurnsPerLevel = GameConfig.GAME_PARAMS.baseTurnsPerLevel,
    seasonsPerLevel = GameConfig.GAME_PARAMS.seasonsPerLevel,
    turnsPerSeason = GameConfig.GAME_PARAMS.turnsPerSeason,
    
    -- Plages de dés par saison
    diceRanges = GameConfig.DICE_RANGES,
    
    -- Objectifs et récompenses
    baseScoreObjective = GameConfig.GAME_PARAMS.baseScoreObjective,
    
    -- Paramètres jeu
    initialDeckSize = GameConfig.GAME_PARAMS.initialDeckSize,
    initialHandSize = GameConfig.GAME_PARAMS.initialHandSize,
    initialGardenSize = GameConfig.GAME_PARAMS.initialGardenSize,
    
    -- Propriétés plantes
    plantConfigs = GameConfig.PLANT_CONFIG
}