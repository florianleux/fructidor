-- Importation des modules
local GameState = require('src.states.game_state')
local CardSystem = require('src.systems.card_system')
local DragDrop = require('src.ui.drag_drop')
local DependencySetup = require('src.utils.dependency_setup')

function love.load(arg)
    math.randomseed(os.time())
    
    -- Vérifier si on est en mode test
    if arg and arg[2] == "--test" then
        runTests()
        return
    end
    
    -- Initialiser le système d'injection de dépendances
    DependencySetup.initialize()
    
    -- Initialiser l'état du jeu
    gameState = GameState.new()
    
    -- Initialiser le système de cartes
    cardSystem = CardSystem.new()
    
    -- Initialiser le système de drag & drop
    dragDrop = DragDrop.new()
end

function love.update(dt)
    -- Mettre à jour l'état du jeu
    gameState:update(dt)
    
    -- Mettre à jour le système d'animation du drag & drop
    dragDrop:update(dt)
end

function love.draw()
    -- Fond
    love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
    
    -- Dessiner l'état du jeu
    gameState:draw()
    
    -- Dessiner les effets de surbrillance si une carte est en cours de déplacement
    if not dragDrop:isAnimating() then
        dragDrop:updateHighlight(gameState.garden, love.mouse.getX(), love.mouse.getY())
    end
    
    -- Dessiner les cartes en main
    cardSystem:drawHand()
    
    -- Dessiner la carte en cours de déplacement ou d'animation (au-dessus de tout)
    dragDrop:draw()
end

function love.mousepressed(x, y, button)
    -- Ne pas traiter les clics pendant une animation
    if dragDrop:isAnimating() then return end
    
    -- Déléguer au GameState pour gérer les clics sur l'interface
    gameState:mousepressed(x, y, button)
    
    -- Clic sur une carte en main
    if button == 1 then
        local card, cardIndex = cardSystem:getCardAt(x, y)
        if card then
            -- Démarrer le drag & drop
            dragDrop:startDrag(card, cardIndex, cardSystem)
        end
    end
end

function love.mousereleased(x, y, button)
    -- Déléguer au GameState
    gameState:mousereleased(x, y, button)
    
    -- Lâcher une carte
    if button == 1 and not dragDrop:isAnimating() then
        dragDrop:stopDrag(gameState.garden)
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