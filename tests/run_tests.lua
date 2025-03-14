
-- Script pour exécuter tous les tests
-- À lancer avec busted depuis la ligne de commande: busted tests/run_tests.lua

-- Simuler l'environnement LÖVE2D si nécessaire
if not love then
    -- Création d'un mock simple pour love
    love = {
        filesystem = {
            getInfo = function(path)
                local lfs = require("lfs")
                local attr = lfs.attributes(path)
                if attr then
                    return {
                        type = attr.mode
                    }
                end
                return nil
            end
        },
        graphics = {
            setColor = function() end,
            rectangle = function() end,
            -- Autres fonctions de rendu simulées ici
        },
        mouse = {
            getX = function() return 0 end,
            getY = function() return 0 end
        }
    }
end

-- Charger la suite de tests
local testSuite = require("tests.test_suite")

-- Exécuter tous les tests
testSuite.run_all_tests()

-- Pour les tests interactifs qui nécessitent LÖVE2D
print("Pour des tests plus complets dans l'environnement LÖVE2D,")
print("exécutez l'application avec la commande:")
print("love . --test")
