# Système de Composants UI avec Dimensions en Pixels

## Présentation

Le système de composants UI de Fructidor permet de créer et gérer les éléments d'interface utilisateur en utilisant des dimensions en pixels basées sur une résolution HD de référence (1920x1080). Ces dimensions sont ensuite automatiquement mises à l'échelle pour s'adapter à la résolution actuelle de la fenêtre.

## Principes de base

### 1. Dimensions en pixels HD

Toutes les dimensions (positions, tailles) sont définies en pixels basés sur la résolution de référence (1920x1080). Par exemple:

```lua
-- Création d'un bouton de 80x30 pixels à la position (100, 200)
local button = Button.new(100, 200, 80, 30, "Cliquez-moi")
```

### 2. Mise à l'échelle automatique

Le système convertit automatiquement ces dimensions HD en valeurs adaptées à la résolution actuelle:

- Si la fenêtre est en 1280x720, toutes les dimensions seront multipliées par 0.667
- Si la fenêtre est en 3840x2160 (4K), toutes les dimensions seront multipliées par 2.0

### 3. Séparation des préoccupations

- `pixelX, pixelY, pixelWidth, pixelHeight`: Valeurs d'origine en pixels HD
- `x, y, width, height`: Valeurs mises à l'échelle utilisées pour le rendu

## Hiérarchie des composants

### UIComponent (Base abstraite)

- Classe de base pour tous les composants d'interface
- Gère la position, les dimensions, la visibilité et la mise à l'échelle
- Méthodes: `update()`, `draw()`, `contains()`, `onEvent()`

### Composants concrets

- `Button`: Bouton interactif avec différents états (normal, hover, pressé, désactivé)
- `Card`: Carte de jeu affichant les informations d'une plante
- Plus à venir: Panel, Label, Checkbox, etc.

## Utilisation du système

### Création directe

```lua
local UIComponent = require('src.ui.components.ui_component')
local Button = require('src.ui.components.button')

-- Créer un bouton avec des dimensions en pixels HD
local myButton = Button.new(100, 200, 80, 30, "Cliquez-moi", function()
    print("Bouton cliqué!")
end)

-- Dans love.update
function love.update(dt)
    myButton:update(dt)
end

-- Dans love.draw
function love.draw()
    ScaleManager.applyScale() -- Appliquer l'échelle
    myButton:draw()
    ScaleManager.restoreScale() -- Restaurer l'échelle
end

-- Dans love.mousepressed
function love.mousepressed(x, y, button)
    local scaledX = x / ScaleManager.scale
    local scaledY = y / ScaleManager.scale
    myButton:onEvent("mousepressed", scaledX, scaledY, button)
end
```

### Utilisation via UIManager (recommandé)

```lua
local UIManager = require('src.ui.ui_manager')

-- Initialisation
function love.load()
    UIManager.initialize()
    
    -- Créer des composants avec des dimensions en pixels HD
    UIManager.createButton(100, 200, 80, 30, "Cliquez-moi", function()
        print("Bouton cliqué!")
    end, "myButton")
end

-- Mise à jour
function love.update(dt)
    UIManager.update(dt)
end

-- Dessin
function love.draw()
    UIManager.draw() -- Gère automatiquement applyScale/restoreScale
end

-- Événements
function love.mousepressed(x, y, button)
    UIManager.handleEvent("mousepressed", x, y, button)
end
```

## Avantages du système

1. **Prévisibilité**: Utilisation de valeurs en pixels réels, intuitives pour les développeurs
2. **Maintenabilité**: Séparation claire entre les valeurs de référence et celles mises à l'échelle
3. **Adaptation automatique**: Support de différentes résolutions sans code supplémentaire
4. **Simplicité**: API uniforme pour tous les composants d'interface

## Bonnes pratiques

1. **Toujours utiliser des valeurs en pixels HD** pour les dimensions, positions et espacements
2. **Utiliser UIManager** pour gérer vos composants quand c'est possible
3. **Ne pas mélanger** les valeurs d'origine et celles mises à l'échelle
4. **Utiliser la hiérarchie de composants** pour créer des interfaces complexes
5. **Utiliser les événements** pour gérer les interactions utilisateur