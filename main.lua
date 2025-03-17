-- Importation des modules
local GameState = require('src.states.game_state')
local CardSystem = require('src.systems.card_system')
local DragDrop = require('src.ui.drag_drop')
local DependencySetup = require('src.utils.dependency_setup')
local DependencyContainer = require('src.utils.dependency_container')
local Garden = require('src.entities.garden')
local ScaleManager = require('src.utils.scale_manager')

-- Module principal pour stocker les références localement
local Game = {
    initialized = false,
    initializationError = nil,
    debug = true -- Activer le mode debug
}

function love.load(arg)
    if Game.debug then
        print("Démarrage de Fructidor en mode debug")
    end
    
    math.randomseed(os.time())
    
    -- Vérifier si on est en mode test
    if arg and arg[2] == "--test" then
        runTests()
        return
    end
    
    -- Tenter d'initialiser le gestionnaire d'échelle
    local success = ScaleManager.initialize()
    if not success then
        Game.initializationError = "Échec d'initialisation du ScaleManager"
        print("ERREUR: " .. Game.initializationError)
        return
    end
    
    if Game.debug then
        print("ScaleManager initialisé avec succès")
        print("Échelle: " .. ScaleManager.scale)
    end
    
    -- Créer les instances principales avec leurs dépendances mutuelles
    -- Nous créons d'abord toutes les instances, puis nous les relions ensemble
    
    -- Créer le jardin
    local garden = Garden.new(3, 2)
    
    -- Créer les systèmes principaux avec leurs dépendances
    local cardSystem = CardSystem.new({
        scaleManager = ScaleManager
    })
    
    if Game.debug then
        print("CardSystem créé avec " .. #cardSystem.hand .. " cartes en main")
    end
    
    local gameState = GameState.new({
        cardSystem = cardSystem,
        garden = garden,
        scaleManager = ScaleManager
    })
    
    local dragDrop = DragDrop.new({
        cardSystem = cardSystem,
        scaleManager = ScaleManager
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
        dragDrop = dragDrop,
        scaleManager = ScaleManager
    })
    
    Game.initialized = true
    if Game.debug then
        print("Vérification des dépendances:")
        print("CardRenderer enregistré: " .. tostring(DependencyContainer.isRegistered("CardRenderer")))
        print("GardenRenderer enregistré: " .. tostring(DependencyContainer.isRegistered("GardenRenderer")))
        print("CardSystem enregistré: " .. tostring(DependencyContainer.isRegistered("CardSystem")))
    end
    
    print("Initialisation de Fructidor terminée avec succès")
end

function love.update(dt)
    -- Vérifier que le jeu est initialisé
    if not Game.initialized then return end
    
    -- Mettre à jour l'état du jeu
    Game.gameState:update(dt)
    
    -- Mettre à jour le système d'animation du drag & drop
    Game.dragDrop:update(dt)
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
    
    -- Vérifier que les objets existent avant de les utiliser
    if not Game.gameState or not Game.cardSystem or not Game.dragDrop then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Erreur: Systèmes principaux non initialisés", 20, 20)
        return
    end
    
    -- Appliquer la transformation d'échelle
    ScaleManager.applyScale()
    
    -- Dessiner l'état du jeu
    Game.gameState:draw()
    
    -- Dessiner les cartes en main
    if Game.debug then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Affichage des cartes...", 10, 450, 0, 2, 2)
    end
    
    Game.cardSystem:drawHand()
    
    -- Dessiner les effets de surbrillance si une carte est en cours de déplacement
    if not Game.dragDrop:isAnimating() then
        -- Utiliser les coordonnées ajustées à l'échelle
        local mouseX = love.mouse.getX() / ScaleManager.scale
        local mouseY = love.mouse.getY() / ScaleManager.scale
        Game.dragDrop:updateHighlight(Game.gameState.garden, mouseX, mouseY)
    end
    
    -- Dessiner la carte en cours de déplacement ou d'animation (au-dessus de tout)
    Game.dragDrop:draw()
    
    -- Restaurer la transformation
    ScaleManager.restoreScale()
    
    -- Afficher des informations de debug si nécessaire (hors échelle)
    if Game.debug or love.keyboard.isDown("f3") then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Scale: " .. string.format("%.2f", ScaleManager.scale), 10, 10)
        love.graphics.print("Resolution: " .. love.graphics.getWidth() .. "x" .. love.graphics.getHeight(), 10, 30)
        love.graphics.print("Cartes en main: " .. #Game.cardSystem.hand, 10, 50)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 70)
    end
end

function love.mousepressed(x, y, button)
    -- Vérifier que le jeu est initialisé
    if not Game.initialized then return end
    
    -- Ne pas traiter les clics pendant une animation
    if Game.dragDrop:isAnimating() then return end
    
    -- Ajuster les coordonnées à l'échelle
    local scaledX = x / ScaleManager.scale
    local scaledY = y / ScaleManager.scale
    
    -- Déléguer au GameState pour gérer les clics sur l'interface
    Game.gameState:mousepressed(scaledX, scaledY, button)
    
    -- Clic sur une carte en main
    if button == 1 then
        local card, cardIndex = Game.cardSystem:getCardAt(scaledX, scaledY)
        if card then
            if Game.debug then
                print("Carte cliquée: " .. card.family .. " (index " .. cardIndex .. ")")
            end
            -- Démarrer le drag & drop
            Game.dragDrop:startDrag(card, cardIndex, Game.cardSystem)
        end
    end
end

function love.mousereleased(x, y, button)
    -- Vérifier que le jeu est initialisé
    if not Game.initialized then return end
    
    -- Ajuster les coordonnées à l'échelle
    local scaledX = x / ScaleManager.scale
    local scaledY = y / ScaleManager.scale
    
    -- Déléguer au GameState
    Game.gameState:mousereleased(scaledX, scaledY, button)
    
    -- Lâcher une carte
    if button == 1 and not Game.dragDrop:isAnimating() then
        Game.dragDrop:stopDrag(Game.gameState.garden)
    end
end

-- Fonction pour gérer le redimensionnement de la fenêtre
function love.resize(width, height)
    if ScaleManager and ScaleManager.initialized then
        ScaleManager.resizeWindow(width, height)
        if Game.debug then
            print("Fenêtre redimensionnée: " .. width .. "x" .. height .. " (échelle: " .. ScaleManager.scale .. ")")
        end
    else
        print("AVERTISSEMENT: Redimensionnement ignoré - ScaleManager non initialisé")
    end
end

-- Fonction pour gérer la touche F11 pour basculer en plein écran
function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    elseif key == "escape" then
        -- Toujours quitter le mode plein écran avec Échap, que le mode soit actif ou non
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            print("Mode plein écran désactivé")
        end
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