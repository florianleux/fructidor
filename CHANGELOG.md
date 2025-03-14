# Changelog Fructidor

Ce document liste les modifications majeures apportées au projet depuis sa création.

## [Non publié] - 2025-03-14

### Ajout
- **Infrastructure de tests**
  - Framework de test Busted simplifié
  - Tests unitaires pour structure du projet, tours et météo
  - Support du lancement en mode test via `love . --test`
  - Documentation des tests

- **Structure du projet**
  - Architecture de dossiers conforme aux spécifications
  - Configuration LÖVE2D avec support de redimensionnement
  - Documentation de suivi MVP

### Développement
- **Système de base**
  - Cycle de jeu complet en 8 tours/4 saisons
  - Potager de base (grille 3×2)
  - Système de météo avec dés soleil et pluie
  - Valeurs saisonnières pour les dés

- **Interface utilisateur**
  - Affichage des tours et des saisons
  - Visualisation des dés météorologiques
  - Système de drag & drop pour les cartes
  - Interface de base pour le jardin

- **Système de cartes**
  - Structure de base des cartes
  - Main du joueur et affichage visuel
  - Placement de cartes dans le potager

## [Initial] - 2025-03-13

### Ajout
- Initialisation du dépôt
- Création de la structure de base du projet
