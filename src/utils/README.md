# Gestion des dépendances dans Fructidor

## Introduction

La gestion des dépendances dans Fructidor est désormais standardisée sur un seul système simple et efficace : le module `Services`. Ce document explique comment utiliser ce système et les bonnes pratiques à suivre.

## Principes de base

Le module `Services` fonctionne comme un registre global permettant :
- D'enregistrer des instances de services
- D'accéder à ces services partout dans l'application
- D'initialiser des services à la demande via des factories (lazy loading)

## Utilisation

### Enregistrement d'un service

```lua
local Services = require('src.utils.services')
local myService = MyService.new()

-- Enregistrer le service
Services.register("MyService", myService)
```

### Accès à un service

```lua
local Services = require('src.utils.services')

-- Récupérer le service
local myService = Services.get("MyService")
```

### Enregistrement d'une factory

Pour un service qui ne doit être créé qu'à la demande :

```lua
Services.registerFactory("LargeService", function()
    return LargeService.new()
end)

-- Plus tard, la première fois que le service est demandé, il sera créé
local largeService = Services.get("LargeService")
```

## Initialisation au démarrage

Le module `service_setup.lua` est responsable de :
1. Enregistrer les factories pour les services communs
2. Initialiser les services principaux au démarrage de l'application

```lua
local ServiceSetup = require('src.utils.service_setup')

-- Dans la fonction love.load
ServiceSetup.initialize({
    gameState = gameState,
    cardSystem = cardSystem,
    garden = garden,
    -- etc.
})
```

## Bonnes pratiques

1. **Nommage cohérent** : Utilisez les noms des classes avec la première lettre en majuscule ("GameState", "Garden", etc.)

2. **Dépendances explicites** : Pour les objets qui dépendent d'autres services, préférez l'injection par constructeur :

```lua
-- Meilleure approche : injection directe
function MyClass.new(params)
    local self = {}
    self.garden = params.garden
    -- ...
end

-- Alternative acceptable : récupération via Services
local garden = Services.get("Garden")
```

3. **Tests unitaires** : Pour les tests, utilisez `Services.reset()` ou `Services.resetAll()` pour réinitialiser l'état.

## Migration depuis l'ancien système

Si vous trouvez du code utilisant `DependencyContainer`, remplacez-le par les équivalents `Services` :

| Ancien code | Nouveau code |
|------------|-------------|
| `DependencyContainer.resolve("Type")` | `Services.get("Type")` |
| `DependencyContainer.register("Type", factory)` | `Services.registerFactory("Type", factory)` |
| `DependencyContainer.registerInstance("Type", instance)` | `Services.register("Type", instance)` |

## Résolutions de problèmes

Si un service est `nil` alors qu'il ne devrait pas l'être :

1. Vérifiez qu'il a bien été enregistré dans `ServiceSetup.initialize()`
2. Assurez-vous que le nom utilisé correspond exactement (sensible à la casse)
3. Vérifiez l'ordre d'initialisation