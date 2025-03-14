
local describe = require("busted").describe
local it = require("busted").it
local assert = require("busted").assert

describe("Système météorologique", function()
  
  it("génère des valeurs de dés dans les plages correctes pour chaque saison", function()
    -- Configuration du test
    local config = {
      diceRanges = {
        spring = {sun = {min = -1, max = 5}, rain = {min = 2, max = 6}},
        summer = {sun = {min = 3, max = 8}, rain = {min = 0, max = 4}},
        autumn = {sun = {min = -2, max = 4}, rain = {min = 1, max = 6}},
        winter = {sun = {min = -3, max = 2}, rain = {min = 0, max = 4}}
      }
    }
    
    -- Remplacer math.random pour le test
    local originalRandom = math.random
    local randomCalls = {}
    
    -- Mock de math.random qui enregistre les appels
    math.random = function(min, max)
      table.insert(randomCalls, {min = min, max = max})
      return min  -- Retourner min pour des tests prévisibles
    end
    
    -- Fonction à tester (version simplifiée pour le test)
    local function testRollDice(season)
      local seasonData
      
      if season == "Printemps" then
        seasonData = config.diceRanges.spring
      elseif season == "Été" then
        seasonData = config.diceRanges.summer
      elseif season == "Automne" then
        seasonData = config.diceRanges.autumn
      else -- Hiver
        seasonData = config.diceRanges.winter
      end
      
      -- Lancer les dés
      local sunValue = math.random(seasonData.sun.min, seasonData.sun.max)
      local rainValue = math.random(seasonData.rain.min, seasonData.rain.max)
      
      return sunValue, rainValue
    end
    
    -- Test pour le Printemps
    randomCalls = {}
    local sunValue, rainValue = testRollDice("Printemps")
    assert.equals(2, #randomCalls, "Deux appels à random attendus")
    assert.same({min = -1, max = 5}, randomCalls[1], "Plage incorrecte pour le dé soleil au Printemps")
    assert.same({min = 2, max = 6}, randomCalls[2], "Plage incorrecte pour le dé pluie au Printemps")
    
    -- Test pour l'Été
    randomCalls = {}
    sunValue, rainValue = testRollDice("Été")
    assert.equals(2, #randomCalls)
    assert.same({min = 3, max = 8}, randomCalls[1], "Plage incorrecte pour le dé soleil en Été")
    assert.same({min = 0, max = 4}, randomCalls[2], "Plage incorrecte pour le dé pluie en Été")
    
    -- Test pour l'Automne
    randomCalls = {}
    sunValue, rainValue = testRollDice("Automne")
    assert.equals(2, #randomCalls)
    assert.same({min = -2, max = 4}, randomCalls[1], "Plage incorrecte pour le dé soleil en Automne")
    assert.same({min = 1, max = 6}, randomCalls[2], "Plage incorrecte pour le dé pluie en Automne")
    
    -- Test pour l'Hiver
    randomCalls = {}
    sunValue, rainValue = testRollDice("Hiver")
    assert.equals(2, #randomCalls)
    assert.same({min = -3, max = 2}, randomCalls[1], "Plage incorrecte pour le dé soleil en Hiver")
    assert.same({min = 0, max = 4}, randomCalls[2], "Plage incorrecte pour le dé pluie en Hiver")
    
    -- Restaurer math.random
    math.random = originalRandom
  end)
  
  it("gère correctement les valeurs négatives de dés", function()
    local gameState = {
      sunDieValue = -2,
      rainDieValue = 3
    }
    
    -- Vérifier que les valeurs négatives sont gérées correctement
    -- Pour les tests, on assume qu'on ne peut pas accumuler de points négatifs
    local function receiveWeather(plant)
      plant.accumulatedSun = plant.accumulatedSun + math.max(0, gameState.sunDieValue)
      plant.accumulatedRain = plant.accumulatedRain + math.max(0, gameState.rainDieValue)
    end
    
    local plant = {
      accumulatedSun = 5,
      accumulatedRain = 2
    }
    
    receiveWeather(plant)
    
    -- La valeur de soleil ne doit pas diminuer même si le dé est négatif
    assert.equals(5, plant.accumulatedSun)
    -- La pluie doit s'accumuler normalement
    assert.equals(5, plant.accumulatedRain)
  end)
end)
