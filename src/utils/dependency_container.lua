-- Conteneur d'injection de dépendances pour Fructidor
-- Ce module agit comme une fabrique (factory) centralisée pour les composants du jeu,
-- ce qui aide à éviter les dépendances circulaires et facilite les tests

local DependencyContainer = {
    -- Stockage des instances
    _instances = {},
    
    -- Stockage des fabriques (factories)
    _factories = {}
}

-- Enregistrer une fabrique pour un type donné
function DependencyContainer.register(typeName, factory)
    if type(factory) ~= "function" then
        error("Factory doit être une fonction")
    end
    
    DependencyContainer._factories[typeName] = factory
    -- Réinitialiser l'instance si elle existait
    DependencyContainer._instances[typeName] = nil
    
    return DependencyContainer
end

-- Enregistrer directement une instance
function DependencyContainer.registerInstance(typeName, instance)
    if instance == nil then
        error("Instance ne peut pas être nil pour le type: " .. typeName)
    end
    
    DependencyContainer._instances[typeName] = instance
    -- Supprimer la factory si elle existait pour éviter toute confusion
    DependencyContainer._factories[typeName] = nil
    
    return DependencyContainer
end

-- Obtenir une instance d'un type (créée à la demande si nécessaire - lazy loading)
function DependencyContainer.resolve(typeName, ...)
    -- Si l'instance existe déjà, la retourner
    if DependencyContainer._instances[typeName] then
        return DependencyContainer._instances[typeName]
    end
    
    -- Vérifier si une fabrique est enregistrée pour ce type
    local factory = DependencyContainer._factories[typeName]
    if not factory then
        error("Aucune fabrique enregistrée pour le type: " .. typeName)
    end
    
    -- Créer et stocker l'instance
    local instance = factory(...)
    DependencyContainer._instances[typeName] = instance
    
    return instance
end

-- Tenter de résoudre un type, renvoie nil si non trouvé au lieu de générer une erreur
function DependencyContainer.tryResolve(typeName, ...)
    if DependencyContainer._instances[typeName] then
        return DependencyContainer._instances[typeName]
    end
    
    local factory = DependencyContainer._factories[typeName]
    if not factory then
        return nil
    end
    
    local success, instance = pcall(factory, ...)
    if not success then
        return nil
    end
    
    DependencyContainer._instances[typeName] = instance
    return instance
end

-- Vérifier si un type est enregistré
function DependencyContainer.isRegistered(typeName)
    return DependencyContainer._factories[typeName] ~= nil or DependencyContainer._instances[typeName] ~= nil
end

-- Réinitialiser une instance spécifique (utile pour les tests)
function DependencyContainer.reset(typeName)
    DependencyContainer._instances[typeName] = nil
    return DependencyContainer
end

-- Réinitialiser toutes les instances
function DependencyContainer.resetAll()
    DependencyContainer._instances = {}
    return DependencyContainer
end

return DependencyContainer