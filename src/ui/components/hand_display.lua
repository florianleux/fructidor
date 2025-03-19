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
    
    -- Z-index pour s'assurer que les cartes apparaissent au-dessus du potager
    self.zIndex = params.zIndex or 10
    
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
    
    -- Positionner les cartes en arc vertical (style éventail)
    -- Calcul des positions des cartes en arc vertical
    local centerX = x + width / 2
    local bottomY = y + height - 20  -- Position en bas de la zone
    local arcHeight = height * 0.6   -- Hauteur de l'arc
    local cardSpacing = math.min(self.cardWidth * 0.7, width / (#hand + 1))
    local totalWidth = cardSpacing * (#hand - 1)
    local startX = centerX - totalWidth / 2
    
    -- Réinitialiser les positions des cartes
    self.cardPositions = {}
    
    -- Dessiner chaque carte - en commençant par les cartes des extrémités pour que le centre soit au-dessus
    -- Déterminer l'ordre de dessin (du côté vers le centre)
    local drawOrder = {}
    local numCards = #hand
    
    -- Remplir l'ordre de dessin pour que les cartes centrales soient dessinées en dernier
    for i = 1, numCards do
        -- Calculer la distance au centre (0 = centre, 1 = extrémité)
        local distanceToCenter = math.abs((i - 0.5) / numCards - 0.5) * 2
        table.insert(drawOrder, {index = i, distance = distanceToCenter})
    end
    
    -- Trier par distance (les plus proches du centre en dernier)
    table.sort(drawOrder, function(a, b) return a.distance > b.distance end)
    
    -- Dessiner les cartes selon l'ordre calculé
    for _, item in ipairs(drawOrder) do
        local i = item.index
        local card = hand[i]
        
        -- Calculer la position en x pour cette carte (distribution uniforme)
        local cardX = startX + (i - 1) * cardSpacing
        
        -- Calculer la hauteur en fonction de la position (arc vertical)
        -- Les cartes au centre sont plus hautes (plus éloignées du bas)
        local normalizedPos = (i - 1) / math.max(1, #hand - 1)  -- 0 à 1
        local cardOffsetY = arcHeight * math.sin(math.pi * normalizedPos)
        local cardY = bottomY - self.cardHeight + cardOffsetY
        
        -- Calculer la rotation - les cartes sur les côtés sont plus inclinées
        -- -15 degrés à gauche, 0 au centre, +15 degrés à droite
        local rotation = (normalizedPos - 0.5) * 0.5  -- -0.25 à +0.25 radians (-15° à +15°)
        
        -- Stocker la position pour la détection de survol
        self.cardPositions[i] = {
            x = cardX,
            y = cardY,
            width = self.cardWidth,
            height = self.cardHeight,
            card = card,
            index = i,
            rotation = rotation  -- Stocker aussi la rotation
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
            -- Vérifier si le point est dans le rectangle de la carte
            -- Détection améliorée qui prend en compte la rotation
            local cardCenterX = pos.x + self.cardWidth/2
            local cardCenterY = pos.y + self.cardHeight/2
            local cardX = mouseX - cardCenterX
            local cardY = mouseY - cardCenterY
            
            -- Appliquer la rotation inverse pour vérifier si le point est dans la carte
            local rotatedX = cardX * math.cos(-pos.rotation) - cardY * math.sin(-pos.rotation)
            local rotatedY = cardX * math.sin(-pos.rotation) + cardY * math.cos(-pos.rotation)
            
            -- Vérifier si le point est dans le rectangle non-rotationné
            if math.abs(rotatedX) <= self.cardWidth/2 and math.abs(rotatedY) <= self.cardHeight/2 then
                self.hoveredCard = i
                break
            end
        end
    end
end

function HandDisplay:mousepressed(x, y, button)
    -- Mettre les coordonnées à l'échelle
    x = x / (self.scaleManager and self.scaleManager.scale or 1)
    y = y / (self.scaleManager and self.scaleManager.scale or 1)

    -- Utiliser l'état de survol actuel pour déterminer quelle carte est cliquée
    if self.hoveredCard and button == 1 then
        local pos = self.cardPositions[self.hoveredCard]
        -- Démarrer le drag & drop de la carte
        if self.dragDrop then
            self.dragDrop:startDrag(pos.card, self.hoveredCard, self.cardSystem)
            return true -- Le clic a été traité
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