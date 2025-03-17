-- Configuration du conteneur d'injection de dépendances
local DependencyContainer = require('src.utils.dependency_container')
local PlantRenderer = require('src.ui.plant_renderer')
local GardenRenderer = require('src.ui.garden_renderer')
local CardRenderer = require('src.ui.card_renderer')

-- Module pour initialiser toutes les dépendances au démarrage de l'application
local DependencySetup = {}

-- Fonction d'initialisation à appeler une seule fois au démarrage
function DependencySetup.initialize(systems)
    systems = systems or {}
    
    -- Enregistrer les renderers en tant que singletons
    DependencyContainer.register("PlantRenderer", function()
        return PlantRenderer.new()
    end)
    
    DependencyContainer.register("GardenRenderer", function()
        return GardenRenderer.new()
    end)
    
    DependencyContainer.register("CardRenderer", function()
        return CardRenderer.new()
    end)
    
    -- Enregistrer les instances des systèmes principales si fournies
    if systems.garden then
        DependencyContainer.registerInstance("Garden", systems.garden)
    end
    
    if systems.cardSystem then
        DependencyContainer.registerInstance("CardSystem", systems.cardSystem)
    end
    
    if systems.gameState then
        DependencyContainer.registerInstance("GameState", systems.gameState)
    end
    
    if systems.dragDrop then
        DependencyContainer.registerInstance("DragDrop", systems.dragDrop)
    end
    
    return true
end

return DependencySetup