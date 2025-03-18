-- Suite de tests simplifiée pour Fructidor
local busted = require("lib.busted")

local TestSuite = {
    -- Liste des tests à exécuter
    tests = {
        "tests.structure.test_project_structure",
        "tests.game.test_turn_increment",
        "tests.weather.test_dice_ranges"
    }
}

-- Fonction pour exécuter tous les tests
function TestSuite.run_all_tests()
    print("\n=== FRUCTIDOR - TESTS UNITAIRES ===\n")
    
    -- Réinitialiser busted avant de commencer
    busted.clear()
    
    local allPassed = true
    
    -- Charger et exécuter chaque test
    for _, testPath in ipairs(TestSuite.tests) do
        print("Chargement du test: " .. testPath)
        
        local success, result = pcall(function()
            return require(testPath)
        end)
        
        if not success then
            print("ERREUR lors du chargement du test: " .. testPath)
            print(result)
            allPassed = false
        end
    end
    
    -- Exécuter tous les tests chargés
    local testsPassed = busted.run()
    
    -- Afficher le résultat global
    print("\n=== RÉSULTAT FINAL ===")
    if testsPassed and allPassed then
        print("SUCCÈS: Tous les tests ont réussi!")
    else
        print("ÉCHEC: Certains tests ont échoué.")
    end
    
    return testsPassed and allPassed
end

return TestSuite