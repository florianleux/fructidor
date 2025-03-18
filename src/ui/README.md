# Architecture de l'Interface Utilisateur de Fructidor

Ce document décrit l'architecture modulaire de l'interface utilisateur de Fructidor.

## Structure Générale

L'interface utilisateur de Fructidor est construite selon une architecture modulaire à composants qui permet:
- Une adaptation facile à différentes tailles d'écran
- Une maintenance simple avec des responsabilités clairement séparées
- Une réutilisation des composants dans différentes parties du jeu

## Organisation des Fichiers

```
src/ui/
├── components/                    # Composants individuels
│   ├── component_base.lua         # Classe de base pour tous les composants
│   ├── season_banner.lua          # Bannière de saison (haut)
│   ├── weather_dice.lua           # Affichage des dés météo
│   ├── garden_display.lua         # Affichage du potager
│   ├── hand_display.lua           # Affichage de la main du joueur
│   └── score_panel.lua            # Panneau de score
├── layout_manager.lua             # Gestionnaire de mise en page
├── ui_manager.lua                 # Coordinateur de l'interface
├── card_renderer.lua              # Rendu des cartes (utilisé par les composants)
├── drag_drop.lua                  # Système de drag & drop
├── garden_renderer.lua            # Rendu du jardin (utilisé par GardenDisplay)
└── plant_renderer.lua             # Rendu des plantes (utilisé par GardenRenderer)
```

## Hiérarchie des Composants

```
UIManager
  └── LayoutManager
       ├── Conteneur "main" (zone principale, 75% largeur)
       │    ├── SeasonBanner
       │    ├── WeatherDice
       │    ├── GardenDisplay
       │    └── HandDisplay
       └── Conteneur "sidebar" (colonne latérale, 25% largeur)
            ├── ScorePanel
            └── [Autres panneaux latéraux à venir]
```

## Système de Positionnement

Chaque composant définit sa position et sa taille par rapport à son conteneur parent:

- **Position relative**: `relX`, `relY` (de 0 à 1, proportion de la taille du parent)
- **Taille relative**: `relWidth`, `relHeight` (de 0 à 1, proportion de la taille du parent)
- **Marges**: Espace en pixels autour du composant

Les calculs de positionnement sont effectués dans `calculateBounds()` qui convertit ces valeurs relatives en coordonnées et dimensions absolues.

## Flux des Événements

1. Les événements souris (`mousepressed`, `mousereleased`, `mousemoved`) partent du `UIManager`
2. Ils sont transmis au `LayoutManager` qui détermine quel conteneur est concerné
3. Le `LayoutManager` propage l'événement aux composants appropriés
4. Chaque composant peut "consommer" l'événement en retournant `true` ou le laisser se propager

## Adaptation à l'Écran

Toute l'interface s'adapte automatiquement à différentes résolutions d'écran:

1. Le `ScaleManager` définit une résolution de référence (1920x1080)
2. Toutes les positions et dimensions sont calculées relativement à cette référence
3. Le système de positionnement relatif des composants assure une disposition cohérente
4. Les tailles des éléments (texte, cartes, etc.) sont proportionnelles à l'espace disponible

## Comment Ajouter un Nouveau Composant

1. Créer une nouvelle classe héritant de `ComponentBase`
2. Implémenter au minimum les méthodes `draw()` et `update(dt)`
3. Ajouter le composant à un conteneur via `layoutManager:addComponent(containerKey, component)`

Exemple:
```lua
-- Dans un nouveau fichier my_component.lua
local ComponentBase = require('src.ui.components.component_base')
local MyComponent = setmetatable({}, {__index = ComponentBase})
MyComponent.__index = MyComponent

function MyComponent.new(params)
    local self = ComponentBase.new({
        id = "my_component",
        relX = params.relX or 0,
        relY = params.relY or 0,
        relWidth = params.relWidth or 0.5,
        relHeight = params.relHeight or 0.1,
        scaleManager = params.scaleManager
    })
    setmetatable(self, MyComponent)
    return self
end

function MyComponent:draw()
    -- Code de dessin
end

function MyComponent:update(dt)
    -- Code de mise à jour
end

return MyComponent

-- Dans ui_manager.lua
local myComponent = MyComponent.new({
    relX = 0.1,
    relY = 0.1,
    scaleManager = self.scaleManager
})
self.layoutManager:addComponent("main", myComponent)
```

## Bonnes Pratiques

1. **Cohésion**: Chaque composant doit avoir une responsabilité unique et claire
2. **Indépendance**: Les composants ne doivent pas dépendre directement les uns des autres
3. **Résilience**: Vérifier les références externes avant de les utiliser (`if not self.gameState then return end`)
4. **Adaptabilité**: Toujours utiliser des dimensions relatives et s'adapter à l'espace disponible
5. **Documentation**: Commenter clairement l'objectif et le fonctionnement de chaque composant
