-- Importation des modules
local GameState = require('src.states.game_state')
local CardSystem = require('src.systems.card_system')
local DragDrop = require('src.ui.drag_drop')
local Garden = require('src.entities.garden')
local ScaleManager = require('src.utils.scale_manager')
local UIManager = require('src.ui.ui_manager')

-- Module principal pour stocker les références globalement accessibles
local Game = {
    initialized = false,
    initializationError = nil
}

function love.load(arg)
    math.randomseed(os.time())
    
    -- Vérifier si on est en mode test
    if arg and arg[2] == "--test" then
        runTests()
        return
    end
    
    -- Initialiser le gestionnaire d'échelle
    local success = ScaleManager.initialize()
    if not success then
        Game.initializationError = "Échec d'initialisation du ScaleManager"
        print("ERREUR: " .. Game.initializationError)
        return
    end
    
    -- Créer les instances principales en utilisant l'injection de dépendances directe
    local garden = Garden.new(3, 2)
    
    local cardSystem = CardSystem.new({
        scaleManager = ScaleManager
    })
    
    local gameState = GameState.new({
        cardSystem = cardSystem,
        garden = garden,
        scaleManager = ScaleManager
    })
    
    local dragDrop = DragDrop.new({
        cardSystem = cardSystem,
        scaleManager = ScaleManager
    })
    
    local uiManager = UIManager.new({
        gameState = gameState,
        cardSystem = cardSystem,
        garden = garden,
        scaleManager = ScaleManager,
        dragDrop = dragDrop,
        nextTurnCallback = function() 
            gameState:nextTurn() 
            -- Mettre à jour l'interface après le changement de tour
            uiManager:updateComponent("seasonBanner")
            uiManager:updateComponent("weatherDice")
            uiManager:updateComponent("garden")
            uiManager:updateComponent("scorePanel")
        end
    })
    
    -- Compléter les dépendances circulaires
    dragDrop.dependencies.uiManager = uiManager
    
    -- Stocker les références localement 
    Game.gameState = gameState
    Game.cardSystem = cardSystem
    Game.dragDrop = dragDrop
    Game.garden = garden
    Game.uiManager = uiManager
    
    -- Piocher quelques cartes pour commencer le jeu
    for i = 1, 5 do
        cardSystem:drawCard()
    end
    
    Game.initialized = true
    print("Initialisation de Fructidor terminée avec succès")
end

function love.update(dt)
    -- Vérifier que le jeu est initialisé
    if not Game.initialized then return end
    
    -- Mettre à jour l'état du jeu
    Game.gameState:update(dt)
    
    -- Mettre à jour le système d'animation du drag & drop
    Game.dragDrop:update(dt)
    
    -- Mettre à jour l'interface utilisateur
    Game.uiManager:update(dt)
end

function love.draw()
    -- Fond
    love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
    
    -- Vérifier si le jeu a rencontré une erreur d'initialisation
    if Game.initializationError then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Erreur d'initialisation: " .. Game.initializationError, 20, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Veuillez vérifier les logs et redémarrer l'application.", 20, 50)
        return
    end
    
    -- Vérifier que le jeu est bien initialisé
    if not Game.initialized then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("Initialisation en cours...", 20, 20)
        return
    end
    
    -- Appliquer la transformation d'échelle
    ScaleManager.applyScale()
    
    -- Dessiner l'interface utilisateur
    Game.uiManager:draw()
    
    -- Dessiner la carte en cours de déplacement
    Game.dragDrop:draw()
    
    -- Restaurer la transformation
    ScaleManager.restoreScale()
    
    -- Afficher des informations de debug si nécessaire
    if love.keyboard.isDown("f3") then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Scale: " .. string.format("%.2f", ScaleManager.scale), 10, 10)
        love.graphics.print("Resolution: " .. love.graphics.getWidth() .. "x" .. love.graphics.getHeight(), 10, 30)
    end
end

function love.mousepressed(x, y, button)
    if not Game.initialized then return end
    
    -- Ajuster les coordonnées à l'échelle
    local scaledX = x / ScaleManager.scale
    local scaledY = y / ScaleManager.scale
    
    -- Déléguer au gestionnaire d'interface
    Game.uiManager:mousepressed(scaledX, scaledY, button)
end

function love.mousereleased(x, y, button)
    if not Game.initialized then return end
    
    -- Ajuster les coordonnées à l'échelle
    local scaledX = x / ScaleManager.scale
    local scaledY = y / ScaleManager.scale
    
    -- Déléguer au gestionnaire d'interface
    Game.uiManager:mousereleased(scaledX, scaledY, button)
    
    -- Lâcher une carte si elle était en cours de déplacement
    if button == 1 and not Game.dragDrop:isAnimating() then
        Game.dragDrop:stopDrag(Game.gameState.garden)
    end
end

function love.mousemoved(x, y, dx, dy)
    if not Game.initialized then return end
    
    -- Ajuster les coordonnées à l'échelle
    local scaledX = x / ScaleManager.scale
    local scaledY = y / ScaleManager.scale
    local scaledDX = dx / ScaleManager.scale
    local scaledDY = dy / ScaleManager.scale
    
    -- Déléguer au gestionnaire d'interface
    Game.uiManager:mousemoved(scaledX, scaledY, scaledDX, scaledDY)
end

function love.resize(width, height)
    if ScaleManager and ScaleManager.initialized then
        ScaleManager.resizeWindow(width, height)
    end
end

function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    elseif key == "escape" and love.window.getFullscreen() then
        love.window.setFullscreen(false)
    end
end

-- Fonction pour exécuter les tests
function runTests()
    print("Exécution des tests unitaires...")
    
    local success, testSuite = pcall(require, "tests.test_suite")
    if not success then
        print("ERREUR: Module de test non trouvé")
        print(testSuite)
        return
    end
    
    local allPassed = testSuite.run_all_tests()
    
    if not love.window or not love.graphics or not love.event then
        os.exit(allPassed and 0 or 1)
    end
end