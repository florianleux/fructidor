# Fichiers à supprimer

Ce document liste les fichiers qui sont devenus obsolètes suite à la migration vers l'architecture unifiée KISS. Ces fichiers peuvent maintenant être supprimés, car leurs fonctionnalités ont été intégrées dans les nouveaux composants.

## Renderers séparés - Prêts à supprimer

- [x] `src/ui/garden_renderer.lua` *(remplacé par garden_component.lua)*
- [x] `src/ui/card_renderer.lua` *(remplacé par card_component.lua)*
- [x] `src/ui/plant_renderer.lua` *(fichier vide, concept intégré dans les composants)*
- [x] `src/ui/layout_manager.lua` *(fichier vide, fonctionnalité intégrée dans ComponentBase)*

## Composants remplacés - Prêts à supprimer

- [x] `src/ui/components/garden_display.lua` *(remplacé par garden_component.lua)*
- [x] `src/ui/components/season_banner.lua` *(remplacé par season_component.lua)*
- [x] `src/ui/components/weather_dice.lua` *(remplacé par weather_component.lua)*
- [x] `src/ui/components/score_panel.lua` *(remplacé par score_component.lua)*
- [x] `src/ui/components/hand_display.lua` *(remplacé par hand_component.lua)*

## Migration effectuée

La migration vers l'architecture unifiée KISS a été complétée avec succès. Tous les renderers et composants ont été remplacés par leurs équivalents unifiés, et toutes les références dans le code ont été mises à jour, notamment dans :

1. `UIManager` - Mise à jour pour utiliser la nouvelle architecture
2. `main.lua` - Suppression des références aux renderers séparés
3. `DragDrop` - Adaptation pour travailler avec les nouveaux noms de composants

## Bénéfices

- Architecture plus simple, cohérente et facile à maintenir
- Réduction du nombre de fichiers (10 fichiers remplacés par 6 nouveaux composants)
- Meilleure séparation des préoccupations
- Association explicite entre modèles et composants