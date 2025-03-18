# Système de gestion des dépendances de Fructidor

Ce document explique la gestion des dépendances dans le projet Fructidor, conçue selon le principe KISS (Keep It Simple, Stupid).

## Philosophie

Le système de dépendances du projet Fructidor suit ces principes:

1. **Simplicité avant tout**: Une implémentation minimaliste mais efficace
2. **Prévisibilité**: Un comportement clair et facile à comprendre
3. **Flexibilité**: Support de plusieurs approches selon les besoins
4. **Testabilité**: Facilité à tester chaque composant indépendamment

## Approches recommandées

### 1. Injection de dépendances via constructeur (RECOMMANDÉ)

C'est l'approche préférée pour la quasi-totalité des cas:

```lua
-- Définition d'une classe
local Entity = {}
Entity.__index = Entity

function Entity.new(dependencies)
    local self = setmetatable({}, Entity)
    self.dependencies = dependencies or {}
    return self
end

-- Utilisation avec injection de dépendances
local entity = Entity.new({
    garden = gardenInstance,
    cardSystem = cardSystemInstance
})
```

Avantages:
- Relations explicites entre composants
- Test facile avec des mocks
- Pas de dépendances globales cachées
- Documentation claire des dépendances

### 2. Conteneur global (SOLUTION DE DERNIER RECOURS)

Un simple conteneur global est disponible pour des cas spécifiques:

```lua
local DI = require('src.utils.dependency_injection')

-- Enregistrer une dépendance
DI.register('garden', gardenInstance)

-- Récupérer une dépendance ailleurs
local garden = DI.get('garden')
```

Cette approche devrait être évitée au maximum et réservée uniquement pour:
- Des composants réellement globaux (configuration, localisation)
- Des situations où l'injection par constructeur n'est pas applicable

## Migration du code existant

Le système précédent était plus complexe et a été simplifié. Des modules de compatibilité ont été maintenus pour assurer la transition en douceur:

- `services.lua` → redirigé vers `dependency_injection.lua`
- `service_setup.lua` → redirigé vers `dependency_injection.lua`
- `dependency_container.lua` → redirigé vers `dependency_injection.lua`
- `dependency_setup.lua` → redirigé vers `dependency_injection.lua`

## Bonnes pratiques

1. **Préférez l'injection via constructeur** dans tous les nouveaux développements
2. **Évitez les dépendances circulaires** qui compliquent la conception
3. **Explicitez les dépendances** pour une meilleure maintenance
4. **Migrez progressivement** le code existant pour utiliser l'injection par constructeur

## Cas d'utilisation

### Interface utilisateur

```lua
local UIManager = {}
UIManager.__index = UIManager

function UIManager.new(dependencies)
    local self = setmetatable({}, UIManager)
    
    -- Validation des dépendances requises
    assert(dependencies.gameState, "UIManager requires gameState")
    assert(dependencies.gardenRenderer, "UIManager requires gardenRenderer")
    
    self.gameState = dependencies.gameState
    self.gardenRenderer = dependencies.gardenRenderer
    
    return self
end
```

### Tests unitaires

```lua
-- Test avec injection de mock
function TestUIManager()
    local mockGameState = { currentTurn = 1, maxTurns = 8 }
    local mockRenderer = { draw = function() end }
    
    local uiManager = UIManager.new({
        gameState = mockGameState,
        gardenRenderer = mockRenderer
    })
    
    -- Test logic...
end
```

## Comparaison avec l'ancienne approche

Le nouveau système est délibérément plus simple que l'ancien qui impliquait:
- Résolution automatique de dépendances
- Enregistrement par type
- Initialisation complexe

La nouvelle approche met l'accent sur la clarté et l'explicité des dépendances.