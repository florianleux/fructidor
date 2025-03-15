-- Importation des modules
local Garden = require('src.entities.garden')
local CardSystem = require('src.systems.card_system')
local DragDrop = require('src.ui.drag_drop')

function love.load(arg)
    math.randomseed(os.time())
    
    -- Vérifier si on est en mode test
    if arg and arg[2] == "--test" then
        runTests()
        return
    end
    
    -- Configuration du jeu
    config = {
        diceRanges = {
            spring = {sun = {min = -1, max = 5}, rain = {min = 2, max = 6}},
            summer = {sun = {min = 3, max = 8}, rain = {min = 0, max = 4}},
            autumn = {sun = {min = -2, max = 4}, rain = {min = 1, max = 6}},
            winter = {sun = {min = -3, max = 2}, rain = {min = 0, max = 4}}
        }
    }
    
    -- État du jeu
    gameState = {
        currentTurn = 1,
        maxTurns = 8,
        currentSeason = "Printemps",
        sunDieValue = 0,
        rainDieValue = 0,
        score = 0,
        objective = 100
    }
    
    -- Initialiser le jardin
    garden = Garden.new(3, 2)
    
    -- Initialiser le système de cartes
    cardSystem = CardSystem.new()
    
    -- Initialiser le système de drag & drop
    dragDrop = DragDrop.new()
    
    -- Rouler les dés initiaux
    rollDice()
end

function love.update(dt)
    -- Mettre à jour le système de drag & drop si une carte est en cours de déplacement
    if dragDrop.dragging then
        dragDrop:updateDrag(love.mouse.getX(), love.mouse.getY())
    end
end

function love.draw()
    -- Fond
    love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
    
    -- Interface tour et saison
    love.graphics.setColor(0.9, 0.95, 0.9)
    love.graphics.rectangle("fill", 10, 10, 580, 40)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Saison: " .. gameState.currentSeason .. " (" .. math.ceil(gameState.currentTurn/2) .. "/4)", 30, 25)
    
    -- Indicateur de tour
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", 10, 60, 580, 30)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.line(50, 75, 550, 75)
    
    -- Cercles des tours
    for i = 1, 8 do
        local x = 50 + (i-1) * 500/7
        if i == gameState.currentTurn then
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("fill", x, 75, 8)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("line", x, 75, 8)
        end
    end
    
    -- Dés et bouton
    love.graphics.setColor(0.8, 0.9, 0.95)
    love.graphics.rectangle("fill", 10, 100, 580, 50)
    
    -- Dé soleil
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("fill", 240, 105, 40, 40, 6)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(gameState.sunDieValue, 255, 115)
    love.graphics.print("Soleil", 245, 130)
    
    -- Dé pluie
    love.graphics.setColor(0.6, 0.8, 1)
    love.graphics.rectangle("fill", 310, 105, 40, 40, 6)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(gameState.rainDieValue, 325, 115)
    love.graphics.print("Pluie", 317, 130)
    
    -- Bouton fin de tour
    love.graphics.setColor(0.6, 0.8, 0.6)
    love.graphics.rectangle("fill", 480, 110, 80, 30, 5)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Fin du tour", 487, 120)
    
    -- Score
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Score: " .. gameState.score .. "/" .. gameState.objective, 10, 160)
    
    -- Grille du potager
    garden:draw()
    
    -- Dessiner les effets de surbrillance si une carte est en cours de déplacement
    if dragDrop.dragging then
        dragDrop:updateHighlight(garden, love.mouse.getX(), love.mouse.getY())
    end
    
    -- Dessiner les cartes en main
    cardSystem:drawHand()
    
    -- Dessiner la carte en cours de déplacement (au-dessus de tout)
    dragDrop:draw()
end

function love.mousepressed(x, y, button)
    -- Clic sur le bouton fin de tour
    if button == 1 and x >= 480 and x <= 560 and y >= 110 and y <= 140 then
        nextTurn()
        return
    end
    
    -- Clic sur une carte en main
    if button == 1 then
        local card, cardIndex = cardSystem:getCardAt(x, y)
        if card then
            -- Marquer la carte comme étant en cours de déplacement
            cardSystem:setDraggingCard(cardIndex)
            dragDrop:startDrag(card, cardIndex, x, y)
        end
    end
end

function love.mousereleased(x, y, button)
    -- Lâcher une carte
    if button == 1 and dragDrop.dragging then
        local placed = dragDrop:stopDrag(garden, cardSystem)
        if placed then
            -- Jouer un son ou autre feedback ici
        end
    end
end

function rollDice()
    local seasonData
    
    if gameState.currentSeason == "Printemps" then
        seasonData = config.diceRanges.spring
    elseif gameState.currentSeason == "Été" then
        seasonData = config.diceRanges.summer
    elseif gameState.currentSeason == "Automne" then
        seasonData = config.diceRanges.autumn
    else -- Hiver
        seasonData = config.diceRanges.winter
    end
    
    -- Lancer les dés
    gameState.sunDieValue = math.random(seasonData.sun.min, seasonData.sun.max)
    gameState.rainDieValue = math.random(seasonData.rain.min, seasonData.rain.max)
end

function nextTurn()
    -- Appliquer les effets météo aux plantes
    for y = 1, garden.height do
        for x = 1, garden.width do
            local cell = garden.grid[y][x]
            if cell.plant then
                -- Vérifier le gel
                if gameState.sunDieValue < cell.plant.frostThreshold then
                    garden:placePlant(nil, x, y) -- Retirer la plante
                else
                    -- Appliquer soleil et pluie
                    cell.plant:receiveSun(math.max(0, gameState.sunDieValue))
                    cell.plant:receiveRain(math.max(0, gameState.rainDieValue))
                end
            end
        end
    end
    
    -- Piocher une carte
    cardSystem:drawCard()
    
    -- Passer au tour suivant
    gameState.currentTurn = gameState.currentTurn + 1
    
    -- Vérifier fin de partie
    if gameState.currentTurn > gameState.maxTurns then
        gameState.currentTurn = 1
    end
    
    -- Mettre à jour la saison
    local season = math.ceil(gameState.currentTurn / 2)
    if season == 1 then
        gameState.currentSeason = "Printemps"
    elseif season == 2 then
        gameState.currentSeason = "Été"
    elseif season == 3 then
        gameState.currentSeason = "Automne"
    elseif season == 4 then
        gameState.currentSeason = "Hiver"
    end
    
    -- Lancer les dés
    rollDice()
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