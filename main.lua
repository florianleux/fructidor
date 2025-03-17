-- Importation des modules
local GameState = require('src.states.game_state')
local CardSystem = require('src.systems.card_system')
local DragDrop = require('src.ui.drag_drop')
local DependencySetup = require('src.utils.dependency_setup')
local DependencyContainer = require('src.utils.dependency_container')
local Garden = require('src.entities.garden')

-- Module principal pour stocker les références localement
local Game = {}

function love.load(arg)
    math.randomseed(os.time())
    
    -- Vérifier si on est en mode test
    if arg and arg[2] == "--test" then
        runTests()
        return
    end
    
    -- Créer les instances principales avec leurs dépendances mutuelles
    -- Nous créons d'abord toutes les instances, puis nous les relions ensemble
    
    -- Créer le jardin
    local garden = Garden.new(3, 2)
    
    -- Créer les systèmes principaux avec leurs dépendances
    local cardSystem = CardSystem.new()
    local gameState = GameState.new({
        cardSystem = cardSystem,
        garden = garden
    })
    local dragDrop = DragDrop.new({
        cardSystem = cardSystem
    })
    
    -- Stocker les références localement 
    Game.gameState = gameState
    Game.cardSystem = cardSystem
    Game.dragDrop = dragDrop
    Game.garden = garden
    
    -- Initialiser le système d'injection de dépendances avec nos instances
    DependencySetup.initialize({
        gameState = gameState,
        cardSystem = cardSystem,
        garden = garden,
        dragDrop = dragDrop
    })
end

function love.update(dt)
    -- Vérifier que le jeu est initialisé
    if not Game.gameState then return end
    
    -- Mettre à jour l'état du jeu
    Game.gameState:update(dt)
    
    -- Mettre à jour le système d'animation du drag & drop
    Game.dragDrop:update(dt)
end

function love.draw()
    -- Fond
    love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
    
    -- Vérifier que les objets existent avant de les utiliser
    if not Game.gameState or not Game.cardSystem or not Game.dragDrop then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Erreur: Systèmes principaux non initialisés", 20, 20)
        return
    end
    
    -- Dessiner l'état du jeu
    Game.gameState:draw()
    
    -- Dessiner les effets de surbrillance si une carte est en cours de déplacement
    if not Game.dragDrop:isAnimating() then
        Game.dragDrop:updateHighlight(Game.gameState.garden, love.mouse.getX(), love.mouse.getY())
    end
    
    -- Dessiner les cartes en main
    Game.cardSystem:drawHand()
    
    -- Dessiner la carte en cours de déplacement ou d'animation (au-dessus de tout)
    Game.dragDrop:draw()
end

function love.mousepressed(x, y, button)
    -- Vérifier que le jeu est initialisé
    if not Game.gameState then return end
    
    -- Ne pas traiter les clics pendant une animation
    if Game.dragDrop:isAnimating() then return end
    
    -- Déléguer au GameState pour gérer les clics sur l'interface
    Game.gameState:mousepressed(x, y, button)
    
    -- Clic sur une carte en main
    if button == 1 then
        local card, cardIndex = Game.cardSystem:getCardAt(x, y)
        if card then
            -- Démarrer le drag & drop
            Game.dragDrop:startDrag(card, cardIndex, Game.cardSystem)
        end
    end
end

function love.mousereleased(x, y, button)
    -- Vérifier que le jeu est initialisé
    if not Game.gameState then return end
    
    -- Déléguer au GameState
    Game.gameState:mousereleased(x, y, button)
    
    -- Lâcher une carte
    if button == 1 and not Game.dragDrop:isAnimating() then
        Game.dragDrop:stopDrag(Game.gameState.garden)
    end
end

-- Fonction pour exécuter les tests
function runTests()
    print("Exécution des tests unitaires...")
    
    -- Vérifier que le module de test existe
    local success, testSuite = pcall(require, "tests.test_suite")
    if not success then
        print("ERREUR: Module de test non trouvé")
        print(testSuite) -- Afficher l'erreur
        return
    end
    
    -- Exécuter tous les tests
    local allPassed = testSuite.run_all_tests()
    
    -- Afficher le résultat final
    if allPassed then
        print("Tous les tests ont réussi!")
    else
        print("Certains tests ont échoué.")
    end
    
    -- Quitter après les tests si en mode ligne de commande
    if not love.window or not love.graphics or not love.event then
        os.exit(allPassed and 0 or 1)
    end
end