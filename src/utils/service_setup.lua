-- Configuration du système de services pour Fructidor
-- DÉPRÉCIÉ: Ce module est maintenu uniquement pour compatibilité
-- et sera supprimé dans une version future.
-- Utilisez l'injection de dépendances directe via le constructeur à la place.

local Services = require('src.utils.services')

-- Module pour initialiser tous les services au démarrage de l'application
local ServiceSetup = {}

-- Fonction d'initialisation à appeler une seule fois au démarrage
function ServiceSetup.initialize(systems)
    systems = systems or {}
    
    -- Enregistrer les instances des systèmes principaux
    local instances = {}
    
    -- Ajouter les systèmes principaux s'ils sont fournis
    if systems.garden then instances.Garden = systems.garden end
    if systems.cardSystem then instances.CardSystem = systems.cardSystem end
    if systems.gameState then instances.GameState = systems.gameState end
    if systems.dragDrop then instances.DragDrop = systems.dragDrop end
    if systems.uiManager then instances.UIManager = systems.uiManager end
    if systems.gardenRenderer then instances.GardenRenderer = systems.gardenRenderer end
    
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