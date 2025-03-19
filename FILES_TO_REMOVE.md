# Fichiers à supprimer

Ce document liste les fichiers qui deviendront obsolètes lorsque la migration vers l'architecture unifiée KISS sera complétée.

## Renderers séparés

Ces fichiers de rendu séparés seront remplacés par les composants unifiés :

- [ ] `src/ui/garden_renderer.lua` *(remplacé par garden_component.lua)*
- [ ] `src/ui/card_renderer.lua` *(remplacé par card_component.lua)*
- [ ] `src/ui/plant_renderer.lua` *(fichier vide, concept intégré dans les composants)*

## Composants à migrer et renommer

- [ ] `src/ui/components/garden_display.lua` *(remplacé par garden_component.lua)*
- [ ] `src/ui/components/season_banner.lua` *(à renommer en season_component.lua)*
- [ ] `src/ui/components/weather_dice.lua` *(à renommer en weather_component.lua)*
- [ ] `src/ui/components/score_panel.lua` *(à renommer en score_component.lua)*
- [ ] `src/ui/components/hand_display.lua` *(à renommer en hand_component.lua)*

## Processus de migration

1. Créer les nouveaux composants unifiés avec le suffixe `_component.lua`
2. Mettre à jour les références dans UIManager et autres fichiers
3. Tester la fonctionnalité pour s'assurer que tout fonctionne correctement
4. Supprimer les anciens fichiers une fois que toutes les références ont été mises à jour

## Consignes pour la revue

Lors de la revue de cette PR, veuillez vérifier les points suivants :

- Tous les composants suivent bien le nouveau modèle d'architecture KISS
- Les comportements et fonctionnalités existants ont été préservés
- Les fichiers obsolètes ont bien été supprimés
- Aucune référence orpheline ne subsiste dans le code
