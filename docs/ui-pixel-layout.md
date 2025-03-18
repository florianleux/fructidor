# Système de Layout Basé sur les Pixels pour Fructidor

Ce document explique le système de positionnement et dimensionnement de l'interface utilisateur de Fructidor, basé sur une référence pixel HD.

## Principes fondamentaux

### Résolution de référence

Toutes les positions et dimensions sont définies en pixels, en se basant sur une résolution de référence HD :

- Largeur : 1920 pixels
- Hauteur : 1080 pixels

Cette référence permet d'avoir un point de départ cohérent pour le design de l'interface, tout en permettant l'adaptation à différentes résolutions d'écran.

### Mise à l'échelle automatique

Le `ScaleManager` s'occupe d'adapter automatiquement ces valeurs de référence à la résolution réelle de l'utilisateur :

- Les positions sont multipliées par le facteur d'échelle calculé
- Les dimensions sont multipliées par le même facteur
- Un facteur d'échelle uniforme (min(scaleX, scaleY)) est utilisé pour conserver les proportions

## Organisation du code

### Fichier de constantes

Toutes les valeurs de référence sont centralisées dans `src/ui/constants.lua` :

```lua
-- Exemples
constants.REFERENCE_WIDTH = 1920
constants.REFERENCE_HEIGHT = 1080
constants.UI_MARGIN = 10
constants.HEADER_HEIGHT = 40
constants.CARD_WIDTH = 108
```

Ces constantes représentent les valeurs en pixels à résolution 1920x1080.

### Utilisation dans les composants

Les composants d'interface utilisent ces constantes en les combinant avec le facteur d'échelle :

```lua
-- Exemple de rendu avec mise à l'échelle
love.graphics.rectangle("fill", 
                       UIConstants.UI_MARGIN, 
                       UIConstants.UI_MARGIN, 
                       UIConstants.MAIN_PANEL_WIDTH * scale, 
                       UIConstants.HEADER_HEIGHT)
```

## Fonctions utilitaires

Le `ScaleManager` fournit des fonctions utilitaires pour convertir entre les valeurs en pixels de référence et les valeurs mises à l'échelle :

- `ScaleManager.pixelToScale(pixelValue)` : Convertit une valeur en pixels de référence vers une valeur mise à l'échelle
- `ScaleManager.scaleToPixel(scaledValue)` : Opération inverse, pour récupérer la valeur en pixels de référence

## Bonnes pratiques

1. **Toujours utiliser les constantes** : Ne pas coder en dur des valeurs en pixels dans les composants
2. **Appliquer l'échelle** : Utiliser `ScaleManager.applyScale()` et `ScaleManager.restoreScale()` pour dessiner à l'échelle
3. **Coordonnées de souris** : Ajuster les coordonnées de souris avec `mouseX / ScaleManager.scale` pour détecter correctement les interactions
4. **Nouvelles valeurs** : Ajouter toute nouvelle constante d'interface dans `src/ui/constants.lua` pour maintenir la centralisation

## Avantages

- **Conception simplifiée** : Travail avec des valeurs de pixels réelles et intuitives
- **Cohérence visuelle** : Maintien des proportions sur toutes les résolutions
- **Maintenance facilitée** : Modification centralisée des dimensions et positions
- **Adaptabilité** : Support naturel des écrans de différentes tailles

## Exemple d'utilisation

```lua
local UIConstants = require('src.ui.constants')

-- Dans une fonction de dessin
function MyComponent:draw()
    -- Appliquer l'échelle globale
    ScaleManager.applyScale()
    
    -- Dessiner en utilisant les constantes
    love.graphics.rectangle("fill", 
                           UIConstants.UI_MARGIN, 
                           UIConstants.UI_MARGIN, 
                           UIConstants.CARD_WIDTH, 
                           UIConstants.CARD_HEIGHT)
    
    -- Restaurer l'échelle
    ScaleManager.restoreScale()
end
```