-- Services - Système de gestion des dépendances simplifié pour Fructidor
-- Ce module est déprécié et sera supprimé dans une version future.
-- Utilisez l'injection de dépendances directe à la place.

local Services = {
    -- Stockage des services
    _services = {},
    
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
function Services.get(name)
    return Services._services[name]
end

-- Enregistre un service
function Services.register(name, service)
    Services._services[name] = service
    return service
end

-- Réinitialise tous les services (utile pour les tests)
function Services.resetAll()
    Services._services = {}
    Services.initialized = false
    return Services
end

return Services
