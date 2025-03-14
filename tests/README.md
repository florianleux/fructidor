
# Tests Unitaires pour Fructidor

Ce dossier contient les tests unitaires du projet Fructidor, organisés par catégorie.

## Structure des tests

```
tests/
├── structure/        # Tests pour la structure du projet
├── state/            # Tests pour la machine à états
├── garden/           # Tests pour le potager
├── game/             # Tests pour la logique de jeu
├── ui/               # Tests pour l'interface utilisateur
├── cards/            # Tests pour le système de cartes
├── weather/          # Tests pour le système météorologique
├── run_tests.lua     # Script pour exécuter tous les tests
└── test_suite.lua    # Rassemblement de tous les tests
```

## Comment exécuter les tests

### Option 1: Exécution dans LÖVE2D

Lancez LÖVE2D avec l'option `--test` :

```bash
love . --test
```

Cela va lancer le jeu en mode test, qui exécutera automatiquement les tests unitaires.

### Option 2: Exécution avec busted (en dehors de LÖVE2D)

Si vous avez installé busted séparément, vous pouvez exécuter :

```bash
busted tests/run_tests.lua
```

Cela fonctionne en dehors de l'environnement LÖVE2D en simulant les composants nécessaires.

## Remarques importantes

1. **Mocks** : Certains tests utilisent des mocks pour simuler des comportements. Assurez-vous que les fonctions mockées reflètent le comportement attendu.

2. **LÖVE2D** : Les tests sont conçus pour fonctionner à la fois dans l'environnement LÖVE2D et en dehors via busted.

3. **Couverture** : Vérifiez régulièrement la couverture des tests pour identifier les parties du code qui nécessitent plus de tests.

## Ajout de nouveaux tests

Pour ajouter un nouveau test :

1. Créez le fichier dans le répertoire approprié selon la fonctionnalité testée
2. Suivez le modèle des tests existants (`describe`, `it`, assertions)
3. Ajoutez une référence au nouveau test dans `test_suite.lua`
