-- src/utils/game_config.lua
-- Module unifié contenant toutes les constantes et configurations du jeu

local GameConfig = {}

--[[
  SECTION 1: ÉNUMÉRATIONS ET CONSTANTES
  Ces valeurs sont des références symboliques qui ne changent pas
--]]

-- Saisons
GameConfig.SEASON = {
  SPRING = "SPRING",
  SUMMER = "SUMMER", 
  AUTUMN = "AUTUMN",
  WINTER = "WINTER"
}

-- Familles de plantes
GameConfig.PLANT_FAMILY = {
  BRASSIKA = "BRASSIKA",
  SOLANA = "SOLANA",
  FABA = "FABA",
  KUKURBITA = "KUKURBITA"
}

-- Couleurs
GameConfig.COLOR = {
  GREEN = "GREEN",
  RED = "RED", 
  YELLOW = "YELLOW",
  BLUE = "BLUE"
}

-- Stades de croissance des plantes
GameConfig.GROWTH_STAGE = {
  SEED = "SEED",         -- Graine
  SPROUT = "SPROUT",     -- Pousse
  FRUIT = "FRUIT"        -- Fruit
}

-- Types de cartes
GameConfig.CARD_TYPE = {
  PLANT = "PLANT",
  OBJECT = "OBJECT"
}

-- Types d'objets
GameConfig.OBJECT_TYPE = {
  STANDALONE = "STANDALONE",
  COMBINABLE = "COMBINABLE"
}

-- États d'une case du jardin
GameConfig.CELL_STATE = {
  EMPTY = "EMPTY",
  OCCUPIED = "OCCUPIED",
  DAMAGED = "DAMAGED"
}

-- Types d'événements
GameConfig.EVENT_TYPE = {
  WEATHER = "WEATHER",
  EXHIBITION = "EXHIBITION",
  NATURAL_DANGER = "NATURAL_DANGER",
  ECONOMIC = "ECONOMIC"
}

-- Contraintes d'événements
GameConfig.CONSTRAINT_TYPE = {
  SUN_MODIFIER = "SUN_MODIFIER",
  RAIN_MODIFIER = "RAIN_MODIFIER",
  FROST_RISK = "FROST_RISK",
  FAMILY_BONUS = "FAMILY_BONUS",
  COLOR_BONUS = "COLOR_BONUS",
  TIME_LIMIT = "TIME_LIMIT"
}

--[[
  SECTION 2: PARAMÈTRES DE JEU
  Ces valeurs peuvent être ajustées pour régler l'équilibrage
--]]

-- Paramètres généraux
GameConfig.GAME_PARAMS = {
  baseTurnsPerLevel = 8,
  seasonsPerLevel = 4,
  turnsPerSeason = 2,
  baseScoreObjective = 100,
  initialDeckSize = 15,
  initialHandSize = 5,
  initialGardenSize = {width = 3, height = 2}
}

-- Plages de dés par saison
GameConfig.DICE_RANGES = {
  [GameConfig.SEASON.SPRING] = {
    sun = {min = -1, max = 5},
    rain = {min = 2, max = 6}
  },
  [GameConfig.SEASON.SUMMER] = {
    sun = {min = 3, max = 8},
    rain = {min = 0, max = 4}
  },
  [GameConfig.SEASON.AUTUMN] = {
    sun = {min = -2, max = 4},
    rain = {min = 1, max = 6}
  },
  [GameConfig.SEASON.WINTER] = {
    sun = {min = -3, max = 2},
    rain = {min = 0, max = 4}
  }
}

-- Propriétés des plantes par famille
GameConfig.PLANT_CONFIG = {
  [GameConfig.PLANT_FAMILY.BRASSIKA] = {
    frostThreshold = -5,
    sunToSprout = 3,
    rainToSprout = 4,
    sunToFruit = 6,
    rainToFruit = 8,
    baseScore = 20
  },
  [GameConfig.PLANT_FAMILY.SOLANA] = {
    frostThreshold = -2,
    sunToSprout = 5,
    rainToSprout = 3,
    sunToFruit = 10,
    rainToFruit = 6,
    baseScore = 30
  }
}

--[[
  SECTION 3: UI ET ÉLÉMENTS GRAPHIQUES
--]]

-- Constantes UI
GameConfig.UI = {
  -- Dimensions des cartes
  CARD = {
    WIDTH = 120,
    HEIGHT = 200,
    CORNER_RADIUS = 3,
    HEADER_HEIGHT = 16,
    TEXT_SCALE = 1.5
  },
  -- Palette de couleurs pour les différents éléments d'interface
  COLORS = {
    -- À compléter selon les besoins
  }
}

return GameConfig