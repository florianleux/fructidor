-- Ce fichier est déprécié et sera supprimé.
-- Utilisez plutôt src.utils.services pour la gestion des dépendances.

-- Conteneur d'injection de dépendances pour Fructidor
-- Ce module agit comme une fabrique (factory) centralisée pour les composants du jeu,
-- ce qui aide à éviter les dépendances circulaires et facilite les tests

local Services = require('src.utils.services')

-- Redirections des méthodes vers Services pour la compatibilité
local DependencyContainer = {
    -- Enregistrer une fabrique pour un type donné
    register = function(typeName, factory)
        return Services.registerFactory(typeName, factory)
    end,
    
    -- Enregistrer directement une instance
    registerInstance = function(typeName, instance)
        return Services.register(typeName, instance)
    end,
    
    -- Obtenir une instance d'un type (créée à la demande si nécessaire)
    resolve = function(typeName, ...)
        return Services.get(typeName)
    end,
    
    -- Tenter de résoudre un type, renvoie nil si non trouvé
    tryResolve = function(typeName, ...)
        return Services.get(typeName)
    end,
    
    -- Vérifier si un type est enregistré
    isRegistered = function(typeName)
        return Services.exists(typeName)
    end,
    
    -- Réinitialiser une instance spécifique (utile pour les tests)
    reset = function(typeName)
        return Services.reset(typeName)
    end,
    
    -- Réinitialiser toutes les instances
    resetAll = function()
        return Services.resetAll()
    end
}

print("AVERTISSEMENT: L'utilisation de DependencyContainer est dépréciée. Veuillez utiliser Services à la place.")

return DependencyContainer