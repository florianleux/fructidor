# Guide de migration : Abandon des Services

Ce document explique comment migrer du système mixte de gestion des dépendances (Services + injection) vers l'approche standardisée d'injection par constructeur.

## Résumé du changement

Le système `Services` et `ServiceSetup` était une source de complexité inutile dans le code, rendant difficile le suivi des dépendances et la compréhension des composants. Nous avons standardisé sur une approche unique : **l'injection de dépendances directe via les constructeurs**.

## Comment migrer votre code

### 1. Remplacer les appels à Services.get()

**Avant :**
```lua
local uiManager = Services.get("UIManager")
```

**Après :**
```lua
-- Dans le constructeur, déclarer la dépendance
function MonModule.new(dependencies)
    local self = setmetatable({}, MonModule)
    self.dependencies = dependencies or {}
    self.uiManager = self.dependencies.uiManager
    -- ...
end

-- Lors de la création de l'instance
local monModule = MonModule.new({
    uiManager = uiManager
})
```

### 2. Gérer les dépendances circulaires

Si deux modules dépendent l'un de l'autre, suivez cette approche :

1. Créez le premier module sans injecter le second
2. Créez le second module en injectant le premier
3. Complétez la dépendance du premier vers le second après création

**Exemple :**
```lua
-- 1. Créer DragDrop sans UIManager
local dragDrop = DragDrop.new({
    cardSystem = cardSystem
})

-- 2. Créer UIManager avec DragDrop
local uiManager = UIManager.new({
    dragDrop = dragDrop,
    -- autres dépendances...
})

-- 3. Compléter la dépendance circulaire
dragDrop.dependencies.uiManager = uiManager
```

### 3. Déclarer les dépendances explicitement

Assurez-vous que chaque module déclare explicitement toutes ses dépendances requises dans son constructeur :

```lua
function MonModule.new(dependencies)
    local self = setmetatable({}, MonModule)
    
    -- Vérifier et stocker les dépendances
    self.dependencies = dependencies or {}
    
    -- Extraire les dépendances essentielles
    self.scaleManager = self.dependencies.scaleManager
    self.gameState = self.dependencies.gameState
    
    -- Vérifier les dépendances obligatoires
    if not self.scaleManager then
        error("MonModule: ScaleManager est requis")
    end
    
    return self
end
```

### 4. Documenter les dépendances

Documentez clairement les dépendances requises par chaque module, idéalement en les listant juste avant ou dans le constructeur :

```lua
-- MonModule - Dépendances requises:
-- - scaleManager: Pour la gestion de l'échelle
-- - gameState: Pour accéder à l'état du jeu
-- - cardSystem (optionnel): Pour les interactions avec les cartes
function MonModule.new(dependencies)
    -- ...
end
```

## Avantages de l'approche standardisée

1. **Clarté** : Chaque module déclare explicitement ses dépendances
2. **Traçabilité** : Le flux de données est évident en lisant le code
3. **Testabilité** : Facilite l'injection de mocks pour les tests
4. **Maintenabilité** : Plus facile de comprendre les responsabilités
5. **Cohérence** : Une seule façon de faire les choses

## Questions fréquentes

### Pourquoi ne pas utiliser un conteneur d'injection de dépendances ?
Pour un projet de cette taille, le bénéfice d'un conteneur est minime par rapport à la complexité qu'il introduit. L'injection manuelle est simple, explicite et suffisante.

### Comment gérer les dépendances communes à plusieurs modules ?
Créez-les dans `main.lua` et injectez-les dans tous les modules qui en ont besoin. C'est explicite et clair.

### Comment procéder avec un module existant qui utilise Services.get() ?
Identifiez toutes les dépendances requises, modifiez le constructeur pour les accepter, puis mettez à jour tous les appels au constructeur pour fournir ces dépendances.