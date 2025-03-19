# Architecture Unifiée des Composants UI

Ce document décrit l'architecture unifiée des composants UI adoptée pour Fructidor, suivant le principe KISS (Keep It Simple, Stupid).

## Principes de conception

L'architecture suit un modèle à deux niveaux:

1. **Modèle** - Gère les données et la logique métier
   - Situé dans `/src/entities` ou `/src/systems`
   - Indépendant de l'affichage et de LÖVE2D
   - Exemples: `Garden`, `Plant`, `GameState`

2. **Composant UI** - Gère l'affichage et l'interaction
   - Situé dans `/src/ui/components`
   - Hérite de `ComponentBase`
   - Possède une référence à son modèle
   - Implémente l'affichage et l'interaction avec LÖVE2D

## Structure standard d'un composant

Tous les composants suivent la même structure de base:

```lua
local XXXComponent = setmetatable({}, {__index = ComponentBase})
XXXComponent.__index = XXXComponent

function XXXComponent.new(params)
    local self = setmetatable(ComponentBase.new(params), XXXComponent)
    
    -- Modèle associé
    self.model = params.model
    
    -- Configuration et paramètres
    -- ...
    
    return self
end

function XXXComponent:draw()
    -- Rendu du composant
end

function XXXComponent:update(dt)
    -- Logique de mise à jour
end

function XXXComponent:mousepressed(x, y, button)
    -- Gestion des clics
    return false -- true si le clic a été traité
end

function XXXComponent:mousemoved(x, y, dx, dy)
    -- Gestion du mouvement de la souris
    return false -- true si l'événement a été traité
end
```

## Composants disponibles

| Composant | Modèle associé | Description |
|-----------|-----------------|-------------|
| `GardenComponent` | `Garden` | Affichage et interaction avec le jardin (grille, plantes) |
| `CardComponent` | `Card` | Rendu et interaction avec une carte individuelle |
| `HandComponent` | `CardSystem` | Affichage et gestion de la main du joueur |
| `SeasonComponent` | `GameState` | Affichage de la saison actuelle et des tours |
| `WeatherComponent` | `GameState` | Dés météorologiques et bouton fin de tour |
| `ScoreComponent` | `GameState` | Affichage du score et des objectifs |

## Association Modèle-Composant

Chaque composant est explicitement associé à un modèle via sa propriété `model` :

```lua
-- Dans le constructeur du composant
self.model = params.model

-- Pour compatibilité avec l'ancienne architecture (exemple)
self.gameState = self.model -- Alias pour faciliter la transition
```

Cette approche permet :
- Une clarification des relations entre composants et données
- Une simplification des tests en isolant le modèle
- Une meilleure séparation des responsabilités

## Avantages de cette architecture

1. **Simplicité**: Deux couches facilement compréhensibles
2. **Cohérence**: Tous les composants suivent le même modèle
3. **Séparation des préoccupations**: Logique métier séparée de l'affichage
4. **Maintenabilité**: Facilite l'évolution et la correction des bugs
5. **Testabilité**: Les modèles peuvent être testés indépendamment de l'UI

## Utilisation avec UIManager

Le `UIManager` instancie et gère les composants UI, en leur fournissant:
- Une référence au modèle approprié
- Des callbacks pour les interactions
- Le positionnement et le dimensionnement

## Bonnes pratiques

1. Toujours référencer le modèle via `self.model` dans les composants
2. Limiter les dépendances entre composants
3. Utiliser les callbacks pour la communication entre composants
4. Conserver la logique métier dans les modèles, pas dans les composants UI
5. Implémenter les méthodes d'événements uniquement si nécessaire

## Transition depuis l'ancienne architecture

Pour la transition depuis l'architecture précédente :
1. Les renderers séparés sont fusionnés dans les composants
2. Les anciens composants sont renommés et adaptés au nouveau modèle
3. Un alias temporaire est conservé (comme `self.gameState = self.model`) pour faciliter la transition
4. Les méthodes de rafraîchissement sont renommées avec un préfixe `refresh*`