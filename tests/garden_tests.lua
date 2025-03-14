-- Tests unitaires pour le jardin
local Garden = require('src.entities.garden')
local Plant = require('src.entities.plant')

local garden = Garden.new(3, 2)
local plant = Plant.new("Brassika", "Vert")

-- Test placement plante
local success = garden:placePlant(plant, 1, 1)
assert(success, "Échec placement plante à 1,1")
assert(garden.grid[1][1].plant == plant, "Plante non trouvée à 1,1")

-- Test détection case occupée
local plant2 = Plant.new("Solana", "Rouge")
local fail = garden:placePlant(plant2, 1, 1)
assert(not fail, "Placement sur case occupée réussi alors qu'il devrait échouer")

-- Test coordonnées hors limites
local outOfBounds = garden:placePlant(plant2, 4, 1)
assert(not outOfBounds, "Placement hors limites réussi alors qu'il devrait échouer")

print("Tests Garden réussis!")
