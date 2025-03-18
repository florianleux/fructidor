# Configuration et Constantes de Fructidor

## Changement de structure

Auparavant, la configuration de Fructidor était répartie entre deux fichiers:
- `constants.lua` : contenant les énumérations et références symboliques
- `config.lua` : contenant les valeurs de jeu ajustables

Cette séparation créait une confusion et un chevauchement conceptuel.

## Nouvelle structure unifiée

Désormais, toute la configuration est centralisée dans un seul module:

### `game_config.lua`

Ce module est divisé en trois sections principales:

1. **Énumérations et constantes**: Valeurs symboliques immuables
   - Saisons, familles de plantes, couleurs, stades de croissance, etc.

2. **Paramètres de jeu**: Valeurs ajustables pour l'équilibrage
   - Dés, scores, configurations des plantes, etc.

3. **UI et éléments graphiques**: Paramètres visuels et dimensions
   - Tailles de cartes, couleurs d'interface, etc.

## Migration de votre code

Pour mettre à jour votre code existant:

```lua
-- Avant (utilisant les deux modules séparés)
local Constants = require('src.utils.constants')
local Config = require('src.utils.config')

local season = Constants.SEASON.SPRING
local diceRange = Config.diceRanges[season]

-- Après (utilisant le module unifié)
local GameConfig = require('src.utils.game_config')

local season = GameConfig.SEASON.SPRING
local diceRange = GameConfig.DICE_RANGES[season]
```

## Modules de compatibilité

Pour faciliter la transition, les anciens modules `constants.lua` et `config.lua` sont maintenus temporairement comme des wrappers redirigeant vers `game_config.lua`.

Cependant, il est recommandé de migrer votre code vers le nouveau module dès que possible, car ces wrappers seront supprimés dans une version future.

## Avantages de cette refonte

- **Clarté conceptuelle**: Un seul endroit pour toutes les configurations
- **Cohérence accrue**: Organisation logique par type de paramètres
- **Maintenance simplifiée**: Facilité pour retrouver et modifier les paramètres
- **Évolution structurée**: Nouvelles sections peuvent être ajoutées proprement