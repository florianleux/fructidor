-- Configuration du conteneur d'injection de dépendances
local DependencyContainer = require('src.utils.dependency_container')
local PlantRenderer = require('src.ui.plant_renderer')
local GardenRenderer = require('src.ui.garden_renderer')
local CardRenderer = require('src.ui.card_renderer')

-- Module pour initialiser toutes les dépendances au démarrage de l'application
local DependencySetup = {}

-- Fonction d'initialisation à appeler une seule fois au démarrage
function DependencySetup.initialize()
    -- Enregistrer les renderers
    DependencyContainer.register("PlantRenderer", function()
        return PlantRenderer.new()
    end)
    
    DependencyContainer.register("GardenRenderer", function()
        return GardenRenderer.new()
    end)
    
    DependencyContainer.register("CardRenderer", function()
        return CardRenderer.new()
    end)
    
    -- D'autres dépendances peuvent être ajoutées ici
    
    return true
end

return DependencySetup