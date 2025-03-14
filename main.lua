function love.load()
    math.randomseed(os.time())
    
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
    
    -- Rouler les dés initiaux
    rollDice()
end

function love.update(dt)
    -- Logique de mise à jour
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
    drawGarden()
end

function love.mousepressed(x, y, button)
    -- Clic sur le bouton fin de tour
    if button == 1 and x >= 480 and x <= 560 and y >= 110 and y <= 140 then
        nextTurn()
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

function drawGarden()
    local cellWidth = 70
    local cellHeight = 70
    local offsetX = 50
    local offsetY = 180
    
    -- Dessiner les cases
    for y = 1, 2 do
        for x = 1, 3 do
            local posX = offsetX + (x-1) * cellWidth
            local posY = offsetY + (y-1) * cellHeight
            
            -- Case
            love.graphics.setColor(0.8, 0.7, 0.5)
            love.graphics.rectangle("fill", posX, posY, cellWidth, cellHeight)
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.rectangle("line", posX, posY, cellWidth, cellHeight)
        end
    end
end
