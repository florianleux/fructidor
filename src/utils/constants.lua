-- src/utils/constants.lua
-- Module contenant toutes les constantes d'énumération pour Fructidor

local Constants = {}

-- Saisons
Constants.SEASON = {
  SPRING = "SPRING",
  SUMMER = "SUMMER", 
  AUTUMN = "AUTUMN",
  WINTER = "WINTER"
}

-- Familles de plantes
Constants.PLANT_FAMILY = {
  BRASSIKA = "BRASSIKA",
  SOLANA = "SOLANA",
  FABA = "FABA",
  KUKURBITA = "KUKURBITA"
}

-- Couleurs
Constants.COLOR = {
  GREEN = "GREEN",
  RED = "RED", 
  YELLOW = "YELLOW",
  BLUE = "BLUE"
}

-- Stades de croissance des plantes (standardisé)
Constants.GROWTH_STAGE = {
  SEED = "SEED",         -- Graine
  SPROUT = "SPROUT",     -- Pousse (rename pour plus de cohérence)
  FRUIT = "FRUIT"        -- Fruit (rename pour cohérence avec le renderer)
}

-- Types de cartes
Constants.CARD_TYPE = {
  PLANT = "PLANT",
  OBJECT = "OBJECT"
}

-- Types d'objets
Constants.OBJECT_TYPE = {
  STANDALONE = "STANDALONE",
  COMBINABLE = "COMBINABLE"
}

-- États d'une case du jardin
Constants.CELL_STATE = {
  EMPTY = "EMPTY",
  OCCUPIED = "OCCUPIED",
  DAMAGED = "DAMAGED"
}

-- Types d'événements
Constants.EVENT_TYPE = {
  WEATHER = "WEATHER",
  EXHIBITION = "EXHIBITION",
  NATURAL_DANGER = "NATURAL_DANGER",
  ECONOMIC = "ECONOMIC"
}

-- Contraintes d'événements
Constants.CONSTRAINT_TYPE = {
  SUN_MODIFIER = "SUN_MODIFIER",
  RAIN_MODIFIER = "RAIN_MODIFIER",
  FROST_RISK = "FROST_RISK",
  FAMILY_BONUS = "FAMILY_BONUS",
  COLOR_BONUS = "COLOR_BONUS",
  TIME_LIMIT = "TIME_LIMIT"
}

-- Constantes graphiques centralisées
Constants.UI = {
  -- Dimensions des cartes (centralisé)
  CARD = {
    WIDTH = 65,
    HEIGHT = 108,
    CORNER_RADIUS = 3,
    HEADER_HEIGHT = 16,
    TEXT_SCALE = 0.84
  },
  -- Couleurs standards (centralisables ultérieurement)
  COLORS = {
    -- ... à compléter au besoin
  }
}

return Constants