# Fructidor

Roguelike à cartes centré sur la gestion d'un jardin potager avec système saisonnier.

## Vision du projet

Fructidor est un jeu vidéo roguelike à base de cartes centré sur la gestion d'un jardin potager. Le joueur optimise son potager, plante et récolte des légumes pour marquer des points, tout en combinant des bonus et des améliorations dans un contexte thématique de jardinage.

## Objectifs et architecture

Cette version du projet est basée sur les principes KISS (Keep It Simple, Stupid) pour maintenir une architecture claire et efficace, adaptée à un prototype Alpha.

### Améliorations récentes

- **Simplification de l'architecture**: Suppression des couches inutiles et des abstractions excessives
- **Adoption exclusive de l'injection de dépendances par constructeur**: Un seul modèle de gestion des dépendances pour plus de clarté
- **Élimination du système de services global**: Flux de données traçable et prévisible
- **Système d'animation simplifié**: Interface plus réactive et code plus maintenable
- **Tests unitaires clarifiés**: Structure de tests cohérente et extensible

## Gestion des dépendances

Le projet utilise exclusivement le modèle d'injection de dépendances par constructeur :

### Principe de base
1. Toutes les dépendances sont explicitement injectées via les constructeurs des modules
2. Les dépendances sont clairement définies et facilement traçables
3. Chaque module déclare précisément ce dont il a besoin pour fonctionner

### Exemple d'utilisation :

```lua
-- Création d'un module avec ses dépendances
local cardSystem = CardSystem.new({
    scaleManager = ScaleManager
})

-- Injection du module comme dépendance d'un autre module
local gameState = GameState.new({
    cardSystem = cardSystem,
    garden = garden,
    scaleManager = ScaleManager
})
```

### Gestion des dépendances circulaires

Pour les cas où des dépendances circulaires sont inévitables (comme entre UIManager et DragDrop), la méthode recommandée est :

```lua
-- Dans main.lua
local dragDrop = DragDrop.new({
    cardSystem = cardSystem,
    scaleManager = ScaleManager
    -- uiManager n'est pas encore créé ici
})

local uiManager = UIManager.new({
    dragDrop = dragDrop,
    -- Autres dépendances...
})

-- Compléter la dépendance circulaire après création
dragDrop.dependencies.uiManager = uiManager
```

## Comment exécuter le projet

1. Assurez-vous d'avoir LÖVE2D version 11.4+ installé
2. Clonez ce dépôt
3. Exécutez `love .` depuis le dossier racine
4. (Option) Pour exécuter les tests: `love . --test`

## Structure du projet

Le projet suit une architecture claire et modulaire:

```
/fructidor
├── main.lua                # Point d'entrée
├── conf.lua                # Configuration LÖVE
├── /src                    # Code source
│   ├── /entities           # Entités du jeu (Garden, Plant)
│   ├── /states             # États du jeu (GameState)
│   ├── /systems            # Systèmes (CardSystem)
│   ├── /ui                 # Interface utilisateur
│   └── /utils              # Utilitaires
├── /assets                 # Ressources
├── /lib                    # Bibliothèques externes
└── /tests                  # Tests unitaires
```

## Développement

Pour participer au développement:

1. Suivez les règles de nommage et d'organisation du code
2. Maintenez la simplicité du code en évitant les abstractions excessives
3. Utilisez **exclusivement** l'injection de dépendances directe via le constructeur
4. Documentez clairement toutes les dépendances requises par chaque module
5. Écrivez des tests pour les nouvelles fonctionnalités
6. Suivez le processus de contribution défini dans le document `docs/Processus de Contribution pour Fructidor.md`