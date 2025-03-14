# CHANGELOG - FRUCTIDOR

## [Unreleased] - 2025-03-14

### Ajouts
- Framework de tests unitaires avec Busted
- Exécution des tests via `love . --test`
- Tests pour la structure du projet, le système de tours et la météo
- Documentation des tests (README)

### Modifications
- Mise à jour de main.lua avec prise en charge des tests

## [0.2.0] - 2025-03-14

### Ajouts
- Système Drag & Drop pour les cartes
- Interface utilisateur améliorée avec feedback visuel
- Système complet de cartes et main du joueur

### Modifications
- Intégration des systèmes dans la boucle de jeu principale
- Correction d'un conflit de noms de fonction dans card_system.lua

## [0.1.0] - 2025-03-14

### Ajouts
- Système de dés météorologiques (soleil et pluie)
- Mécanisme de saisons avec valeurs de dés différentes
- Gestion des conditions météorologiques extrêmes (gel)
- Affichage des valeurs de dés dans l'interface

## [0.0.1] - 2025-03-13

### Ajouts
- Structure initiale du projet LÖVE2D
- Architecture des dossiers (src, assets, lib)
- Grille de jeu 3×2 pour le potager
- Système de tours et saisons
- Bouton "Fin de tour" et transitions
- Interface utilisateur basique

### Configuration
- Organisation du code en composants (entités, systèmes, états)
- Mise en place du flux de jeu principal