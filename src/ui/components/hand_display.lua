-- Composant d'affichage de la main du joueur
local ComponentBase = require('src.ui.components.component_base')

local HandDisplay = setmetatable({}, {__index = ComponentBase})
HandDisplay.__index = HandDisplay

function HandDisplay.new(params)
    local self = setmetatable(ComponentBase.new(params), HandDisplay)
    
    -- Paramètres spécifiques à l'affichage de la main
    self.cardSystem = params.cardSystem
    self.dragDrop = params.dragDrop
    
    -- Dimensions des cartes
    self.cardWidth = 80
    self.cardHeight = 120
    
    -- Couleurs
    self.colors = {
        background = {0.9, 0.9, 0.9, 1},
        cardBackground = {1, 1, 1, 1},
        cardBorder = {0.7, 0.7, 0.7, 1},
        cardText = {0.2, 0.2, 0.2, 1},
        plantCard = {0.8, 0.95, 0.8, 1},
        objectCard = {0.95, 0.9, 0.8, 1},
        rarityCommon = {0.7, 0.7, 0.7, 1},
        rarityUncommon = {0.5, 0.8, 0.5, 1},
        rarityRare = {0.4, 0.6, 0.9, 1},
        familyBrassika = {0.7, 0.85, 0.7, 1},
        familySolana = {0.9, 0.8, 0.5, 1},
        familyFaba = {0.7, 0.8, 0.9, 1},
        colorRed = {0.9, 0.5, 0.5, 1},
        colorGreen = {0.5, 0.9, 0.5, 1},
        colorBlue = {0.5, 0.5, 0.9, 1},
        colorYellow = {0.9, 0.9, 0.5, 1},
        highlight = {1, 1, 0.7, 0.3}
    }
    
    -- État du survol
    self.hoveredCard = nil
    self.cardPositions = {} -- Stocke les positions des cartes pour détection survol
    
    return self
end

function HandDisplay:draw()
    -- Convertir les coordonnées pixel en coordonnées d'écran
    local x, y, width, height = self:getScaledBounds()
    
    -- Dessiner le fond
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", x, y, width, height, 5)
    
    -- Récupérer les cartes en main depuis le système de cartes
    local hand = self.cardSystem and self.cardSystem:getHand() or {}
    
    -- Si aucune carte, afficher un message
    if #hand == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.print("Main vide", x + width/2 - 30, y + height/2 - 10)
        return
    end
    
    -- Calculer les positions des cartes en disposition horizontale
    -- Place les cartes côte à côte avec un léger chevauchement si nécessaire
    local cardSpacing = math.min(self.cardWidth + 10, width / (#hand + 1))
    local totalWidth = cardSpacing * (#hand - 1) + self.cardWidth
    local startX = x + (width - totalWidth) / 2
    local baseY = y + height - self.cardHeight - 20  -- Positionnement en bas
    
    -- Valeurs d'élévation pour l'arc
    local maxElevation = 40
    
    -- Réinitialiser les positions des cartes
    self.cardPositions = {}
    
    -- Dessiner chaque carte
    for i, card in ipairs(hand) do
        -- Calculer la position horizontale de la carte
        local normalizedPosition = (#hand > 1) and ((i - 1) / (#hand - 1) * 2 - 1) or 0
        local elevation = maxElevation * (1 - math.abs(normalizedPosition))
        
        local cardX = startX + (i - 1) * cardSpacing
        local cardY = baseY - elevation
        
        -- Rotation légère pour l'effet d'arc
        local rotation = normalizedPosition * 0.2
        
        -- Stocker la position pour la détection de survol
        self.cardPositions[i] = {
            x = cardX,
            y = cardY,
            width = self.cardWidth,
            height = self.cardHeight,
            card = card,
            index = i,
            rotation = rotation
        }
        
        -- Si cette carte est en train d'être déplacée, ne pas l'afficher ici
        if self.dragDrop and self.dragDrop:isDragging() and i == self.dragDrop:getDraggingCardIndex() then
            -- Sauter cette carte
        else
            -- Dessiner la carte avec sa rotation
            self:drawCard(card, cardX, cardY, rotation, i == self.hoveredCard)
        end
    end
end

function HandDisplay:drawCard(card, x, y, rotation, isHovered)
    -- Sauvegarder l'état actuel de la transformation
    love.graphics.push()
    
    -- Appliquer la transformation pour la rotation
    love.graphics.translate(x + self.cardWidth/2, y + self.cardHeight/2)
    love.graphics.rotate(rotation)
    love.graphics.translate(-self.cardWidth/2, -self.cardHeight/2)
    
    -- Dessiner le fond de la carte selon son type
    if card.type == "plant" then
        love.graphics.setColor(unpack(self.colors.plantCard))
    else
        love.graphics.setColor(unpack(self.colors.objectCard))
    end
    
    local borderRadius = 5
    love.graphics.rectangle("fill", 0, 0, self.cardWidth, self.cardHeight, borderRadius)
    
    -- Bordure de la carte
    love.graphics.setColor(unpack(self.colors.cardBorder))
    love.graphics.rectangle("line", 0, 0, self.cardWidth, self.cardHeight, borderRadius)
    
    -- Si la carte est survolée, ajouter une surbrillance
    if isHovered then
        love.graphics.setColor(unpack(self.colors.highlight))
        love.graphics.rectangle("fill", 0, 0, self.cardWidth, self.cardHeight, borderRadius)
    end
    
    -- Dessiner le contenu de la carte
    love.graphics.setColor(unpack(self.colors.cardText))
    
    -- Nom de la carte
    love.graphics.print(card.name or "Carte", 5, 5, 0, 0.8, 0.8)
    
    -- Pour les plantes, afficher la famille et la couleur
    if card.type == "plant" then
        -- Couleur de famille
        local familyColor = self.colors["family"..card.family] or self.colors.cardText
        love.graphics.setColor(unpack(familyColor))
        love.graphics.print(card.family or "?", 5, 20, 0, 0.7, 0.7)
        
        -- Couleur de plante
        local colorName = card.color or "?"
        local colorValue = self.colors["color"..colorName] or self.colors.cardText
        love.graphics.setColor(unpack(colorValue))
        love.graphics.rectangle("fill", self.cardWidth - 15, 5, 10, 10)
        
        -- Dessiner un symbole pour la plante
        love.graphics.setColor(0.3, 0.7, 0.3)
        love.graphics.rectangle("fill", 10, 40, self.cardWidth - 20, 20)
    else
        -- Pour les objets, afficher le type d'objet
        love.graphics.print("Objet: " .. (card.objectType or "?"), 5, 20, 0, 0.7, 0.7)
        
        -- Dessiner un symbole pour l'objet
        love.graphics.setColor(0.7, 0.6, 0.4)
        love.graphics.rectangle("fill", 10, 40, self.cardWidth - 20, 20)
    end
    
    -- Description de la carte (en bas)
    love.graphics.setColor(unpack(self.colors.cardText))
    local description = card.description or "Pas de description"
    
    -- Limiter la longueur de la description pour qu'elle tienne sur la carte
    if #description > 30 then
        description = description:sub(1, 27) .. "..."
    end
    
    love.graphics.printf(description, 5, self.cardHeight - 40, self.cardWidth - 10, "left", 0, 0.6, 0.6)
    
    -- Restaurer l'état de transformation
    love.graphics.pop()
end

function HandDisplay:update(dt)
    -- Mettre à jour l'état du survol de carte
    local mouseX, mouseY = love.mouse.getPosition()
    mouseX = mouseX / (self.scaleManager and self.scaleManager.scale or 1)
    mouseY = mouseY / (self.scaleManager and self.scaleManager.scale or 1)
    
    -- Réinitialiser l'état de survol
    self.hoveredCard = nil
    
    -- Vérifier si la souris survole une carte
    for i, pos in ipairs(self.cardPositions) do
        -- Si cette carte est en train d'être déplacée, ne pas considérer le survol
        if not (self.dragDrop and self.dragDrop:isDragging() and i == self.dragDrop:getDraggingCardIndex()) then
            -- Pour la détection précise, il faudrait prendre en compte la rotation
            -- Mais pour simplifier, nous utilisons le rectangle englobant
            if mouseX >= pos.x and mouseX <= pos.x + pos.width and
               mouseY >= pos.y and mouseY <= pos.y + pos.height then
                self.hoveredCard = i
                break
            end
        end
    end
end

function HandDisplay:mousepressed(x, y, button)
    -- Vérifier si le clic est sur une carte
    for i, pos in ipairs(self.cardPositions) do
        if x >= pos.x and x <= pos.x + pos.width and
           y >= pos.y and y <= pos.y + pos.height then
            -- Si le clic est avec le bouton gauche
            if button == 1 then
                -- Démarrer le drag & drop de la carte
                if self.dragDrop then
                    self.dragDrop:startDrag(pos.card, i, self.cardSystem)
                    return true -- Le clic a été traité
                end
            end
        end
    end
    
    return false -- Le clic n'a pas été traité
end

function HandDisplay:updateHand()
    -- Cette méthode est appelée pour rafraîchir l'affichage 
    -- quand le contenu de la main change
    
    -- Pour l'instant, il suffit de laisser le système de dessin récupérer 
    -- les données directement depuis le cardSystem à chaque frame
end

return HandDisplay