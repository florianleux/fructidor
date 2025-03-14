
local describe = require("busted").describe
local it = require("busted").it
local assert = require("busted").assert
local mock = require("busted").mock
local before_each = require("busted").before_each

describe("Système de tours", function()
  local GameState
  local originalNextTurn
  
  before_each(function()
    -- Sauvegarder l'état global si nécessaire
    _G.gameState = {
      currentTurn = 1,
      maxTurns = 8,
      currentSeason = "Printemps",
      sunDieValue = 0,
      rainDieValue = 0
    }
    
    -- Créer des mocks pour les fonctions nécessaires
    _G.rollDice = function() end
    
    -- Charger la fonction nextTurn depuis le code principal
    originalNextTurn = _G.nextTurn
    -- Si nextTurn est dans un autre module, il faudrait l'adapter
  end)
  
  it("incrémente correctement le compteur de tours", function()
    -- Arrange
    _G.gameState.currentTurn = 3
    
    -- Act
    nextTurn()
    
    -- Assert
    assert.equals(4, _G.gameState.currentTurn)
  end)
  
  it("réinitialise le compteur de tours après le tour 8", function()
    -- Arrange
    _G.gameState.currentTurn = 8
    
    -- Act
    nextTurn()
    
    -- Assert
    assert.equals(1, _G.gameState.currentTurn)
  end)
  
  it("met à jour correctement la saison quand le tour change", function()
    -- Test pour Printemps (tours 1-2)
    _G.gameState.currentTurn = 1
    nextTurn()
    assert.equals("Printemps", _G.gameState.currentSeason)
    
    -- Test pour Été (tours 3-4)
    _G.gameState.currentTurn = 2
    nextTurn()
    assert.equals("Été", _G.gameState.currentSeason)
    
    -- Test pour Automne (tours 5-6)
    _G.gameState.currentTurn = 4
    nextTurn()
    assert.equals("Automne", _G.gameState.currentSeason)
    
    -- Test pour Hiver (tours 7-8)
    _G.gameState.currentTurn = 6
    nextTurn()
    assert.equals("Hiver", _G.gameState.currentSeason)
  end)
  
  it("appelle rollDice après avoir mis à jour le tour", function()
    -- Arrange
    local called = false
    _G.rollDice = function() called = true end
    
    -- Act
    nextTurn()
    
    -- Assert
    assert.is_true(called, "rollDice n'a pas été appelé")
  end)
end)
