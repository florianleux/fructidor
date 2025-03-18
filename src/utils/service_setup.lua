-- Configuration du système de services pour Fructidor
local Services = require('src.utils.services')
local PlantRenderer = require('src.ui.plant_renderer')
local GardenRenderer = require('src.ui.garden_renderer')
local CardRenderer = require('src.ui.card_renderer')

-- Module pour initialiser tous les services au démarrage de l'application
local ServiceSetup = {}

-- Enregistrer les factories pour les renderers
function ServiceSetup.registerFactories()
    -- Enregistrer les renderers en tant que singletons via des factories
    Services.registerFactory("PlantRenderer", function()
        return PlantRenderer.new()
    end)
    
    Services.registerFactory("GardenRenderer", function()
        return GardenRenderer.new()
    end)
    
    Services.registerFactory("CardRenderer", function()
        return CardRenderer.new()
    end)
    
    -- Autres factories peuvent être ajoutées ici à l'avenir
    
    return true
end

-- Fonction d'initialisation à appeler une seule fois au démarrage
function ServiceSetup.initialize(systems)
    systems = systems or {}
    
    -- Enregistrer les factories
    ServiceSetup.registerFactories()
    
    -- Enregistrer les instances des systèmes principaux
    local instances = {}
    
    -- Ajouter les systèmes principaux s'ils sont fournis
    if systems.garden then instances.Garden = systems.garden end
    if systems.cardSystem then instances.CardSystem = systems.cardSystem end
    if systems.gameState then instances.GameState = systems.gameState end
    if systems.dragDrop then instances.DragDrop = systems.dragDrop end
    if systems.uiManager then instances.UIManager = systems.uiManager end
    
    -- Ajouter le ScaleManager s'il est fourni et initialisé
    if systems.scaleManager then
        if systems.scaleManager.initialized then
            instances.ScaleManager = systems.scaleManager
        else
            print("AVERTISSEMENT: ScaleManager fourni mais non initialisé")
        end
    end
    
    -- Initialiser les services avec toutes les instances
    Services.initialize(instances)
    
    return true
end

return ServiceSetup