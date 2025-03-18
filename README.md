# Fructidor

Roguelike à cartes centré sur la gestion d'un jardin potager avec système saisonnier.

## Vision du projet

Fructidor est un jeu vidéo roguelike à base de cartes centré sur la gestion d'un jardin potager. Le joueur optimise son potager, plante et récolte des légumes pour marquer des points, tout en combinant des bonus et des améliorations dans un contexte thématique de jardinage.

## Objectifs et architecture

Cette version du projet est basée sur les principes KISS (Keep It Simple, Stupid) pour maintenir une architecture claire et efficace, adaptée à un prototype Alpha.

### Améliorations récentes

- **Simplification de l'architecture**: Suppression des couches inutiles et des abstractions excessives
- **Standardisation de la gestion des dépendances**: Utilisation d'un seul système (Services)
- **Cohérence de configuration**: Centralisation dans un seul module
- **Système d'animation simplifié**: Interface plus réactive et code plus maintenable
- **Tests unitaires clarifiés**: Structure de tests cohérente et extensible

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
│   └── /utils              # Utilitaires et services
├── /assets                 # Ressources
├── /lib                    # Bibliothèques externes
└── /tests                  # Tests unitaires
```

## Développement

Pour participer au développement:

1. Suivez les règles de nommage et d'organisation du code
2. Maintenez la simplicité du code en évitant les abstractions excessives
3. Écrivez des tests pour les nouvelles fonctionnalités
4. Suivez le processus de contribution défini dans le document `docs/Processus de Contribution pour Fructidor.md`