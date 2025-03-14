
# FRUCTIDOR - SUIVI DE DÉVELOPPEMENT
> Document de travail interne - Format optimisé pour suivi d'avancement
> Tests détaillés dans `/tests/test_suite.lua`

## NOTES DE DÉVELOPPEMENT
- Début projet: 14/03/2025
- MVP actuel: 1
- Tâche actuelle: Structure initiale
- Problèmes bloquants: aucun
- Dernière mise à jour: 14/03/2025

## PRIORITÉS
- Finaliser structure initiale
- Implémenter machine à états
- Créer rendu basique du plateau

## DÉCISIONS & MODIFICATIONS
1. 

## Légende
- [ ] À faire
- [🔄] En cours
- [✓] Terminé
- [⚠️] Problème identifié
- [↪️] Reporté au MVP suivant

## ÉTAT GLOBAL: MVP 1 - Fondations (Jours 1-3)
> Progression: 0/7 tâches complétées

### Structure initiale
- [ ] Projet LÖVE2D de base
- [ ] Architecture dossiers (src, assets, lib)
- [ ] Configuration Git
- [ ] Tests: `test_project_structure` (vérifie l'intégrité de la structure du projet)

### État de jeu basique
- [ ] Machine à états (menu, jeu)
- [ ] Structure GameState
- [ ] Boucle de jeu principale
- [ ] Tests: `test_state_transitions` (vérifie que la transition entre les états Menu et Jeu fonctionne correctement)

### Représentation plateau
- [ ] Grille 3×2 cliquable
- [ ] Rendu visuel cases
- [ ] Sélection case
- [ ] Tests: `test_grid_coordinates` (vérifie que les coordonnées de grille sont correctement calculées à partir des positions de souris)

### Système de tours
- [ ] Compteur tours (1-8)
- [ ] Bouton "Tour suivant"
- [ ] Transitions entre tours
- [ ] Tests: `test_turn_increment` (vérifie que le compteur de tours s'incrémente correctement et déclenche les changements de saison appropriés)

### Système de saisons
- [ ] Saisons liées aux tours
- [ ] Affichage saison actuelle
- [ ] Indicateurs visuels saisonniers
- [ ] Tests: `test_season_changes` (vérifie que les saisons changent après 2 tours et dans le bon ordre)

### Interface minimale
- [ ] Disposition éléments principaux
- [ ] Zone jeu + colonne info
- [ ] Indicateurs tour/saison
- [ ] Tests: `test_ui_elements_position` (vérifie que tous les éléments d'interface sont correctement positionnés et visibles)

### Structure cartes
- [ ] Classe Card (attributs base)
- [ ] Rendu visuel cartes
- [ ] Main joueur (5 cartes)
- [ ] Tests: `test_card_attributes` (vérifie que les attributs des cartes sont correctement initialisés et accessibles)

---

## MVP 2: Mécaniques de Base (Jours 4-6)
> Non commencé

### Système météorologique
- [ ] Dés soleil et pluie
- [ ] Valeurs par saison
- [ ] Affichage valeurs
- [ ] Tests: `test_dice_ranges` (vérifie que les valeurs des dés restent dans les plages définies pour chaque saison)

### Classe Plant
- [ ] Structure de base
- [ ] Attributs fondamentaux
- [ ] Affichage sur plateau
- [ ] Tests: `test_plant_creation` (vérifie qu'une instance Plant est correctement créée à partir d'une Card)

### Plantation
- [ ] Placement carte sur case
- [ ] Création Plant depuis Card
- [ ] Feedback visuel plantation
- [ ] Tests: `test_plant_placement` (vérifie qu'une plante ne peut être placée que sur une case vide)

### Premier stade croissance
- [ ] Transition graine → plant
- [ ] Accumulation ressources
- [ ] Indicateurs progression
- [ ] Tests: `test_growth_accumulation` (vérifie que les points soleil/pluie s'accumulent correctement selon les valeurs des dés)

### Stade mature
- [ ] Transition plant → mature
- [ ] Seuils Brassika
- [ ] Indicateurs maturité
- [ ] Tests: `test_maturity_transition` (vérifie qu'une plante passe au stade mature quand elle atteint les seuils requis)

### Récolte
- [ ] Interaction récolte
- [ ] Calcul score
- [ ] Libération case
- [ ] Tests: `test_harvest_scoring` (vérifie que le score calculé pour une plante récoltée correspond à la valeur attendue)

### Scoring
- [ ] Compteur cumulatif
- [ ] Objectif (100 points)
- [ ] Indicateur progression
- [ ] Tests: `test_score_accumulation` (vérifie que le score total s'incrémente correctement après chaque récolte)

---

## MVP 3: Profondeur Tactique (Jours 7-9)
> Non commencé

### Famille Solana
- [ ] Configuration complète
- [ ] Différenciation avec Brassika
- [ ] Valeurs et seuils
- [ ] Tests: `test_solana_config` (vérifie que les seuils de Solana sont différents de ceux de Brassika et conformes aux spécifications)

### Rendu Solana
- [ ] Représentation visuelle propre
- [ ] Stades de croissance
- [ ] Indicateurs besoins
- [ ] Tests: `test_visual_distinction` (vérifie que les instances de Solana et Brassika ont des rendus visuels distincts)

### Mécanisme gel
- [ ] Seuil gel par famille
- [ ] Vérifications saisonnières
- [ ] Effet gel sur plantes
- [ ] Tests: `test_frost_damage` (vérifie que les plantes sous leur seuil de gel sont correctement affectées)

### Base objets
- [ ] Classe Object
- [ ] Types objets
- [ ] Placement plateau
- [ ] Tests: `test_object_placement` (vérifie que les objets standalone sont correctement placés sur des cases vides)

### Épicéa protecteur
- [ ] Protection gel
- [ ] Effet cases adjacentes
- [ ] Indicateur protection
- [ ] Tests: `test_epicea_protection` (vérifie que les plantes adjacentes à l'Épicéa reçoivent le bonus de protection contre le gel)

### Feedback visuel
- [ ] Animation plantation
- [ ] Indicateurs croissance/météo
- [ ] Feedback actions
- [ ] Tests: `test_visual_feedback` (vérifie que les actions impossibles déclenchent un feedback visuel approprié)

### Équilibrage initial
- [ ] Valeurs dés par saison
- [ ] Besoins Brassika vs Solana
- [ ] Tests stratégies
- [ ] Tests: `test_strategy_viability` (vérifie qu'une stratégie basée uniquement sur Brassika et une stratégie basée uniquement sur Solana peuvent atteindre l'objectif)

---

## MVP 4: Objets et Synergies (Jours 10-12)
> Non commencé

### Paillage
- [ ] Combinaison avec plante
- [ ] Réduction besoins pluie
- [ ] Indicateur visuel
- [ ] Tests: `test_mulch_effect` (vérifie que les plantes avec paillage ont bien leurs besoins en pluie réduits de 25%)

### Tuteur
- [ ] Accélération accumulation
- [ ] Compatibilité plantes
- [ ] Rendu avec plante
- [ ] Tests: `test_tutor_boost` (vérifie que les plantes avec tuteur accumulent +2 points soleil/pluie par tour)

### Système adjacence
- [ ] Détection cases adjacentes
- [ ] Structure effets proximité
- [ ] Base synergies
- [ ] Tests: `test_adjacency_detection` (vérifie que les cases adjacentes sont correctement identifiées pour chaque position du plateau)

### Synergies famille
- [ ] Bonus adjacence même famille
- [ ] Calcul/application bonus
- [ ] Indicateurs synergie
- [ ] Tests: `test_family_synergy_bonus` (vérifie que le bonus de score pour des plantes de même famille adjacentes est correctement appliqué)

### Système couleurs
- [ ] Attribut couleur
- [ ] Variantes (R,V,J,B)
- [ ] Préparation synergies
- [ ] Tests: `test_color_assignment` (vérifie que les plantes reçoivent correctement un attribut couleur valide)

### Journal actions
- [ ] Enregistrement actions
- [ ] Affichage événements
- [ ] Historique colonne info
- [ ] Tests: `test_action_logging` (vérifie que les actions principales sont correctement enregistrées dans le journal)

### Tutoriel
- [ ] Infobulles explicatives
- [ ] Conseils contextuels
- [ ] Aide nouveaux joueurs
- [ ] Tests: `test_tooltip_visibility` (vérifie que les infobulles s'affichent correctement au survol des éléments concernés)

---

## MVP 5: Événements et Défis (Jours 13-15)
> Non commencé

### Structure événements
- [ ] Classe Event
- [ ] Contraintes/compensations
- [ ] Intégration GameState
- [ ] Tests: `test_event_loading` (vérifie que les événements sont correctement chargés depuis la configuration)

### Événement canicule
- [ ] Modification dés soleil
- [ ] Effets sur croissance
- [ ] Indicateurs visuels
- [ ] Tests: `test_heatwave_effect` (vérifie que l'événement canicule augmente correctement les valeurs du dé soleil)

### Événement gel précoce
- [ ] Risque hors saison
- [ ] Protection objets
- [ ] Feedback visuel
- [ ] Tests: `test_early_frost_risk` (vérifie que le risque de gel est augmenté pendant l'événement)

### Système contraintes
- [ ] Application niveau
- [ ] Ajustement objectifs
- [ ] Feedback contraintes
- [ ] Tests: `test_constraint_objectives` (vérifie que les objectifs de score sont correctement ajustés en fonction des contraintes)

### Équilibrage scoring
- [ ] Révision valeurs
- [ ] Bonus synergies
- [ ] Tests stratégies
- [ ] Tests: `test_synergy_scoring` (vérifie que les bonus de synergies sont équilibrés)

### Interface complète
- [ ] Tous indicateurs
- [ ] Cohérence visuelle
- [ ] Organisation information
- [ ] Tests: `test_ui_information_display` (vérifie que toutes les informations nécessaires sont visibles)

### Test/débogage
- [ ] Correction bugs
- [ ] Validation mécaniques
- [ ] Tests complets
- [ ] Tests: `test_game_completion` (vérifie qu'une partie complète peut être jouée sans erreurs)

---

## MVP 6: Post-Alpha (Jours 16-20)
> Non commencé

### Retour utilisateur
- [ ] Collecte données tests
- [ ] Ajustements prioritaires
- [ ] Correctifs urgents
- [ ] Tests: `test_critical_fixes` (vérifie que les problèmes majeurs identifiés par les testeurs ont été corrigés)

### Hub basique
- [ ] Écran entre niveaux
- [ ] Représentation visuelle
- [ ] Navigation
- [ ] Tests: `test_hub_navigation` (vérifie que la navigation entre le hub et les niveaux fonctionne correctement)

### Florins
- [ ] Gain post-niveau
- [ ] Affichage monnaie
- [ ] Structure transactions
- [ ] Tests: `test_florin_rewards` (vérifie que les florins sont correctement attribués en fonction du score)

### Déblocage permanent
- [ ] Extension potager
- [ ] Persistance entre runs
- [ ] Feedback visuel
- [ ] Tests: `test_garden_extension` (vérifie que l'extension du potager est correctement appliquée)

### Sauvegarde
- [ ] Sauvegarde progression
- [ ] Structure données
- [ ] Chargement auto
- [ ] Tests: `test_save_load` (vérifie que la sauvegarde et le chargement de la progression fonctionnent)

### Menu principal
- [ ] Écran titre
- [ ] Options nouvelle partie/continuer
- [ ] UI cohérente
- [ ] Tests: `test_menu_options` (vérifie que toutes les options du menu principal sont fonctionnelles)

### Alpha complète
- [ ] Équilibrage final
- [ ] Documentation
- [ ] Préparation distribution
- [ ] Tests: `test_alpha_stability` (vérifie la stabilité générale du jeu dans différentes conditions)
