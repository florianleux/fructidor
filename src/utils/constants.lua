-- src/utils/constants.lua
-- COMPATIBILITÉ: Ce module est maintenu pour la rétrocompatibilité et redirige vers game_config.lua

local GameConfig = require('src.utils.game_config')

-- Message avertissant de la dépréciation
print("AVERTISSEMENT: Le module 'constants.lua' est déprécié. Utilisez 'game_config.lua' à la place.")

-- Créer une copie des sections constantes de GameConfig
local Constants = {}

Constants.SEASON = GameConfig.SEASON
Constants.PLANT_FAMILY = GameConfig.PLANT_FAMILY
Constants.COLOR = GameConfig.COLOR
Constants.GROWTH_STAGE = GameConfig.GROWTH_STAGE
Constants.CARD_TYPE = GameConfig.CARD_TYPE
Constants.OBJECT_TYPE = GameConfig.OBJECT_TYPE
Constants.CELL_STATE = GameConfig.CELL_STATE
Constants.EVENT_TYPE = GameConfig.EVENT_TYPE
Constants.CONSTRAINT_TYPE = GameConfig.CONSTRAINT_TYPE
Constants.UI = GameConfig.UI

return Constants