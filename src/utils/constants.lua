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

-- Stades de croissance des plantes
Constants.GROWTH_STAGE = {
  SEED = "SEED",
  PLANT = "PLANT",
  FRUITING = "FRUITING"
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

return Constants