-- Services - Un système de service simple pour Fructidor
-- Ce module remplace le système d'injection de dépendances précédent
-- en proposant une solution plus légère et directe

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

-- Vérifie si un service existe
function Services.exists(name)
    return Services._services[name] ~= nil
end

-- Réinitialise tous les services (utile pour les tests)
function Services.reset()
    Services._services = {}
    Services.initialized = false
end

return Services
