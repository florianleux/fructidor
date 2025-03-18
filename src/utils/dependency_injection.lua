--[[
Module de gestion des dépendances simplifié pour Fructidor

Ce module fournit une solution minimaliste mais efficace pour:  
1. Gérer les dépendances globales (si nécessaire)  
2. Favoriser l'injection de dépendances directe via les constructeurs  

Principe KISS (Keep It Simple, Stupid) appliqué:
- Un simple conteneur global accessible partout si nécessaire  
- Pas de code complexe d'instanciation automatique  
- Pas de résolution récursive de dépendances  
- Documentation claire sur l'utilisation recommandée  
]]

local DI = {
    _container = {}, -- Conteneur simple pour les dépendances globales
    initialized = false
}

-- Enregistrer une dépendance dans le conteneur global
function DI.register(name, instance)
    if DI._container[name] then
        print("Attention: Remplacement d'une dépendance existante '" .. name .. "'")
    end
    
    DI._container[name] = instance
    return instance -- Retourner l'instance pour chaînage
end

-- Récupérer une dépendance depuis le conteneur global
function DI.get(name)
    if not DI._container[name] then
        print("Avertissement: Dépendance non trouvée '" .. name .. "'")
        return nil
    end
    
    return DI._container[name]
end

-- Vérifier si une dépendance existe
function DI.exists(name)
    return DI._container[name] ~= nil
end

-- Méthode d'initialisation simple
function DI.initialize()
    if DI.initialized then return true end
    
    DI._container = {} -- Réinitialisation du conteneur
    DI.initialized = true
    
    return true
end

-- Nettoyer le conteneur (utile pour les tests)
function DI.clear()
    DI._container = {}
    DI.initialized = false
end

-- Message d'usage recommandé
DI.USAGE_GUIDE = [[
Utilisation recommandée des dépendances dans Fructidor:

1. PRÉFÉRÉ: Injection de dépendances directe via constructeurs
   local entity = Entity.new({ 
     dependency1 = dep1,
     dependency2 = dep2 
   })

2. EN DERNIER RECOURS: Utilisation du conteneur global
   local dep = DI.get('dependencyName')
]]

return DI