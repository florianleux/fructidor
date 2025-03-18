# Architecture UI simplifiée de Fructidor

## Vue d'ensemble

L'architecture UI de Fructidor a été simplifiée pour faciliter le développement rapide du prototype alpha, tout en conservant une structure claire et extensible. Cette approche privilégie la simplicité et la vitesse de développement plutôt que l'abstraction complexe à ce stade précoce du projet.

## Composants principaux

### ComponentBase

La classe de base pour tous les composants d'interface utilisateur, offrant:
- Positionnement direct avec coordonnées absolues (x, y, width, height)
- Gestion de visibilité 
- Détection de survol et de clic
- Méthodes communes pour le rendu et les interactions

```lua
local component = ComponentBase.new({
  x = 100, 
  y = 200,
  width = 300,
  height = 150,
  id = "score_panel"  -- Identifiant optionnel
})
```

### LayoutManager

Gère la collection de composants UI et coordonne:
- Les écrans multiples (main, hub, menu)
- Le rendu des composants dans l'ordre approprié
- L'acheminement des entrées utilisateur
- Le basculement entre différents écrans

### UIManager

Point d'entrée principal pour l'interface utilisateur, responsable de:
- La création des composants pour chaque écran
- La coordination entre les composants et les systèmes du jeu
- La gestion des mises à jour et animations

## Avantages de l'approche simplifiée

1. **Développement accéléré**: Moins de code à écrire et maintenir
2. **Facilité de compréhension**: Flux de données direct et intuitif
3. **Débogage simplifié**: Positions fixes plus faciles à visualiser
4. **Performances optimisées**: Moins de calculs de positionnement relatif

## Composants spécifiques

- **GardenDisplay**: Affiche la grille du potager et gère les interactions
- **SeasonBanner**: Affiche la saison et le tour actuels
- **WeatherDice**: Montre les dés météo et le bouton de fin de tour
- **ScorePanel**: Affiche le score et l'objectif
- **HandDisplay**: Affiche et gère la main du joueur

## Adaptation aux différentes résolutions

Bien que cette architecture privilégie la simplicité, elle conserve une compatibilité de base avec différentes résolutions d'écran grâce à :

1. L'utilisation de pourcentages de l'écran pour définir les positions de base
2. L'application du facteur d'échelle global via scaleManager

## Extension future

Cette architecture simplifiée servira de base solide pour le prototype alpha. Dans les versions futures, nous pourrons l'enrichir progressivement avec:

- Un système de thèmes plus robuste
- Une adaptation automatique aux différentes résolutions
- Des animations et transitions plus sophistiquées
- Un système d'accessibilité avancé