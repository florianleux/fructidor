# Architecture Simplifiée

## Principes KISS appliqués

L'architecture de Fructidor a été simplifiée en appliquant le principe KISS (Keep It Simple, Stupid) pour améliorer la maintenabilité et réduire la complexité inutile.

## Modifications majeures

### 1. Gestion des dépendances
- Suppression de `DependencyContainer` au profit du module `Services`
- Uniformisation de l'approche d'injection de dépendances

### 2. Configuration
- Centralisation dans `game_config.lua`
- Suppression des fichiers de compatibilité redondants

### 3. Interface utilisateur
- Suppression de la couche `LayoutManager`
- Simplification de `ComponentBase`
- Communication directe entre composants et `UIManager`

### 4. Animations
- Réduction du système d'animation complexe
- Implémentation minimaliste mais efficace

### 5. Tests unitaires
- Utilisation exclusive de la version simplifiée de Busted
- Structure de tests plus cohérente

## Bénéfices

- **Compréhension facilitée** : Le code est plus direct et plus facile à suivre
- **Maintenance simplifiée** : Moins de niveaux d'indirection
- **Performances améliorées** : Moins de surcharge et de calculs inutiles
- **Développement accéléré** : Plus facile d'ajouter et de modifier des fonctionnalités

## Organisation du code

Le principe directeur est désormais "suffisamment de structure, pas trop de structure" avec une organisation qui suit la complexité réelle du projet plutôt qu'une architecture prématurément optimisée pour un système beaucoup plus vaste.