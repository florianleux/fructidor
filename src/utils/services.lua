-- Services - Système de gestion des dépendances standardisé pour Fructidor
-- Ce module remplace DependencyContainer en proposant une solution plus simple

local Services = {
    -- Stockage des services
    _services = {},
    
    -- Stockage des factories
    _factories = {},
    
    -- Indique si les services ont été initialisés
    initialized = false
}

-- Initialise les services avec les instances fournies
function Services.initialize(instances)
    for name, instance in pairs(instances) do
        Services._services[name] = instance
    end
    Services.initialized = true
    return true
end

-- Récupère un service par son nom
-- Si le service n'existe pas encore mais qu'une factory est enregistrée,
-- crée et stocke l'instance à la demande (lazy loading)
function Services.get(name)
    -- Si l'instance existe déjà, la retourner
    if Services._services[name] then
        return Services._services[name]
    end
    
    -- Vérifier si une factory est enregistrée
    local factory = Services._factories[name]
    if factory then
        -- Créer et stocker l'instance
        local instance = factory()
        Services._services[name] = instance
        return instance
    end
    
    -- Renvoyer nil si aucun service ni factory n'est trouvé
    return nil
end

-- Enregistre un service
function Services.register(name, service)
    Services._services[name] = service
    return service
end

-- Enregistre une factory pour créer le service à la demande
function Services.registerFactory(name, factory)
    if type(factory) ~= "function" then
        error("Factory doit être une fonction")
    end
    
    Services._factories[name] = factory
    -- Réinitialiser l'instance si elle existait
    Services._services[name] = nil
    
    return Services
end

-- Vérifie si un service existe ou peut être créé
function Services.exists(name)
    return Services._services[name] ~= nil or Services._factories[name] ~= nil
end

-- Réinitialise un service spécifique
function Services.reset(name)
    Services._services[name] = nil
    return Services
end

-- Réinitialise tous les services (utile pour les tests)
function Services.resetAll()
    Services._services = {}
    Services.initialized = false
    return Services
end

return Services
