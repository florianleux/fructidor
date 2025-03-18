-- Composant d'affichage de la main du joueur
local ComponentBase = require('src.ui.components.component_base')

local HandDisplay = setmetatable({}, {__index = ComponentBase})
HandDisplay.__index = HandDisplay

function HandDisplay.new(params)
    local self = ComponentBase.new({
        id = "hand_display",
        pixelX = params.pixelX or 0,
        pixelY = params.pixelY or 756,     -- 70% de 1080
        pixelWidth = params.pixelWidth or 1920,  -- 100% de 1920
        pixelHeight = params.pixelHeight or 324,  -- 30% de 1080
        margin = params.margin or {top=10, right=10, bottom=10, left=10},
        scaleManager = params.scaleManager
    })
    
    setmetatable(self, HandDisplay)
    
    -- Référence au système de cartes
    self.cardSystem = params.cardSystem
    
    -- Référence au système de drag & drop
    self.dragDrop = params.dragDrop
    
    -- Paramètres d'affichage des cartes
    self.cardParams = {
        width = 120,   -- Largeur de base d'une carte
        height = 200,  -- Hauteur de base d'une carte
        overlap = 0.7, -- Facteur de chevauchement (0 = pas de chevauchement, 1 = chevauchement total)
        arcRadius = 0.8, -- Rayon de l'arc pour disposition en éventail (0-1)
        arcAngle = 0.3,  -- Angle de l'arc en radians
        hoverScale = 1.2, -- Facteur d'agrandissement au survol
        zoomDuration = 0.2 -- Durée de l'animation de zoom
    }
    
    -- État des cartes
    self.cards = {}
    
    -- État de survol
    self.hoverIndex = nil
    self.hoverProgress = 0
    
    return self
end

-- Calcule la position de chaque carte dans la main
function HandDisplay:calculateCardPositions()
    if not self.cardSystem then return end
    
    local hand = self.cardSystem:getHand()
    if not hand then return end
    
    local numCards = #hand
    self.cards = {}
    
    if numCards <= 0 then return end
    
    -- Adapter la taille des cartes en fonction de l'espace disponible
    local maxCardWidth = self.width / (numCards * (1 - self.cardParams.overlap) + self.cardParams.overlap)
    local cardWidth = math.min(self.cardParams.width, maxCardWidth)
    local cardHeight = (cardWidth / self.cardParams.width) * self.cardParams.height
    
    -- S'assurer que la hauteur ne dépasse pas l'espace disponible
    if cardHeight > self.height * 0.9 then
        local scale = (self.height * 0.9) / cardHeight
        cardHeight = cardHeight * scale
        cardWidth = cardWidth * scale
    end
    
    -- Calculer l'espacement entre les cartes
    local spacing = cardWidth * (1 - self.cardParams.overlap)
    
    -- Position centrale
    local centerX = self.x + self.width / 2
    local bottomY = self.y + self.height - 20
    
    -- Disposition en arc
    local radius = self.width * self.cardParams.arcRadius
    local totalAngle = self.cardParams.arcAngle
    local startAngle = math.pi / 2 - totalAngle / 2
    
    -- Si très peu de cartes, réduire l'angle
    if numCards <= 3 then
        totalAngle = totalAngle * (numCards / 3)
        startAngle = math.pi / 2 - totalAngle / 2
    end
    
    -- Calculer la position de chaque carte
    for i, card in ipairs(hand) do
        local angle
        if numCards > 1 then
            angle = startAngle + (i - 1) * (totalAngle / (numCards - 1))
        else
            angle = math.pi / 2 -- Angle central si une seule carte
        end
        
        local x = centerX + math.cos(angle) * radius - cardWidth / 2
        local y = bottomY - math.sin(angle) * radius - cardHeight
        
        -- Rotation pour l'effet d'éventail
        local rotation = (angle - math.pi/2) * 0.8
        
        self.cards[i] = {
            x = x,
            y = y,
            width = cardWidth,
            height = cardHeight,
            rotation = rotation,
            card = card,
            originalIndex = i,
            hover = false,
            hoverProgress = 0
        }
    end
end

function HandDisplay:draw()
    if not self.visible or not self.cardSystem then return end
    
    -- Recalculer les positions si nécessaire
    if #self.cards == 0 or not self.cards[1] then
        self:calculateCardPositions()
    end
    
    -- Fond de la zone de main
    love.graphics.setColor(0.85, 0.85, 0.85, 0.7)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Dessiner les cartes de la droite vers la gauche (pour que les premières soient au-dessus)
    for i = #self.cards, 1, -1 do
        local cardInfo = self.cards[i]
        
        -- Ne pas dessiner la carte en train d'être déplacée
        if self.dragDrop and self.dragDrop:isDragging() and
           self.dragDrop:getDraggingCardIndex() == cardInfo.originalIndex then
            goto continue
        end
        
        -- Calculer l'échelle de la carte (agrandie si survolée)
        local scale = 1
        if cardInfo.hover then
            scale = 1 + (self.cardParams.hoverScale - 1) * cardInfo.hoverProgress
        end
        
        -- Sauvegarder l'état de transformation
        love.graphics.push()
        
        -- Translater au centre de la carte pour la rotation
        love.graphics.translate(cardInfo.x + cardInfo.width/2, cardInfo.y + cardInfo.height)
        
        -- Appliquer la rotation
        love.graphics.rotate(cardInfo.rotation)
        
        -- Appliquer l'échelle
        love.graphics.scale(scale, scale)
        
        -- Translater à l'origine de la carte
        love.graphics.translate(-cardInfo.width/2, -cardInfo.height)
        
        -- Dessiner la carte
        self:drawCard(cardInfo.card, 0, 0, cardInfo.width, cardInfo.height)
        
        -- Restaurer l'état de transformation
        love.graphics.pop()
        
        ::continue::
    end
end

-- Dessine une carte individuelle
function HandDisplay:drawCard(card, x, y, width, height)
    if not card then return end
    
    -- Fond de la carte
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x, y, width, height, 5)
    
    -- Bordure de la carte
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", x, y, width, height, 5)
    
    -- Couleur selon le type de carte
    local typeColor
    if card.type == "plant" then
        if card.family == "Brassika" then
            typeColor = {0.7, 0.9, 0.7}  -- Vert pour Brassika
        elseif card.family == "Solana" then
            typeColor = {0.9, 0.7, 0.5}  -- Orange pour Solana
        else
            typeColor = {0.8, 0.8, 0.9}  -- Bleu clair pour autres
        end
    elseif card.type == "object" then
        typeColor = {0.9, 0.9, 0.7}  -- Jaune pour objets
    else
        typeColor = {0.8, 0.8, 0.8}  -- Gris pour inconnu
    end
    
    -- En-tête de la carte avec la couleur du type
    love.graphics.setColor(typeColor)
    love.graphics.rectangle("fill", x, y, width, height * 0.2, 5, 5, 0, 0)
    
    -- Nom de la carte
    love.graphics.setColor(0, 0, 0)
    local fontSize = width * 0.15
    love.graphics.setFont(love.graphics.newFont(fontSize))
    
    local name = card.name or (card.family or "Carte")
    love.graphics.printf(name, x, y + height * 0.05, width, "center")
    
    -- Type de carte
    local typeText = card.type or ""
    fontSize = width * 0.12
    love.graphics.setFont(love.graphics.newFont(fontSize))
    love.graphics.printf(typeText, x, y + height * 0.25, width, "center")
    
    -- Caractéristiques spécifiques selon le type
    if card.type == "plant" then
        -- Afficher la famille et les besoins
        fontSize = width * 0.10
        love.graphics.setFont(love.graphics.newFont(fontSize))
        local infoY = y + height * 0.4
        love.graphics.printf("Famille: " .. (card.family or ""), x + width * 0.1, infoY, width * 0.8, "left")
        
        if card.sunToSprout and card.rainToSprout then
            infoY = infoY + fontSize * 1.5
            love.graphics.printf("Soleil: " .. card.sunToSprout, x + width * 0.1, infoY, width * 0.8, "left")
            infoY = infoY + fontSize * 1.5
            love.graphics.printf("Pluie: " .. card.rainToSprout, x + width * 0.1, infoY, width * 0.8, "left")
        end
        
        if card.baseScore then
            infoY = infoY + fontSize * 1.5
            love.graphics.printf("Score: " .. card.baseScore, x + width * 0.1, infoY, width * 0.8, "left")
        end
    elseif card.type == "object" then
        -- Afficher les effets de l'objet
        fontSize = width * 0.10
        love.graphics.setFont(love.graphics.newFont(fontSize))
        local infoY = y + height * 0.4
        
        if card.objectType then
            love.graphics.printf("Type: " .. card.objectType, x + width * 0.1, infoY, width * 0.8, "left")
            infoY = infoY + fontSize * 1.5
        end
        
        -- Afficher les bonus s'ils existent
        if card.bonuses then
            for name, value in pairs(card.bonuses) do
                if value ~= 0 then
                    love.graphics.printf(name .. ": " .. value, x + width * 0.1, infoY, width * 0.8, "left")
                    infoY = infoY + fontSize * 1.5
                end
            end
        end
    end
end

function HandDisplay:update(dt)
    -- Mettre à jour les animations de survol
    for i, cardInfo in ipairs(self.cards) do
        if cardInfo.hover then
            cardInfo.hoverProgress = math.min(1, cardInfo.hoverProgress + dt / self.cardParams.zoomDuration)
        else
            cardInfo.hoverProgress = math.max(0, cardInfo.hoverProgress - dt / self.cardParams.zoomDuration)
        end
    end
end

function HandDisplay:calculateBounds(parentX, parentY, parentWidth, parentHeight)
    -- Appeler la méthode de la classe parente
    ComponentBase.calculateBounds(self, parentX, parentY, parentWidth, parentHeight)
    
    -- Recalculer les positions des cartes après le repositionnement
    self:calculateCardPositions()
end

-- Fonction utilitaire pour trouver la carte sous un point
function HandDisplay:getCardAtPoint(x, y)
    for i, cardInfo in ipairs(self.cards) do
        -- Simplification: utiliser un rectangle englobant sans tenir compte de la rotation
        if x >= cardInfo.x and x <= cardInfo.x + cardInfo.width and
           y >= cardInfo.y and y <= cardInfo.y + cardInfo.height then
            return cardInfo.card, cardInfo.originalIndex, i
        end
    end
    return nil, nil, nil
end

function HandDisplay:mousepressed(x, y, button)
    if not self.visible or not self.cardSystem then return false end
    
    -- Vérifier si une carte est cliquée
    local card, originalIndex, displayIndex = self:getCardAtPoint(x, y)
    if card and button == 1 and self.dragDrop then
        -- Démarrer le drag & drop
        self.dragDrop:startDrag(card, originalIndex, self.cardSystem)
        return true
    end
    
    return false
end

function HandDisplay:mousemoved(x, y, dx, dy)
    -- Mettre à jour l'état de survol
    local hoverChanged = false
    for i, cardInfo in ipairs(self.cards) do
        local wasHover = cardInfo.hover
        
        -- Simplification: utiliser un rectangle englobant sans tenir compte de la rotation
        cardInfo.hover = x >= cardInfo.x and x <= cardInfo.x + cardInfo.width and
                        y >= cardInfo.y and y <= cardInfo.y + cardInfo.height
        
        if wasHover ~= cardInfo.hover then
            hoverChanged = true
        end
    end
    
    return hoverChanged
end

-- Méthode pour mettre à jour la main (appelée lorsque les cartes changent)
function HandDisplay:updateHand()
    self:calculateCardPositions()
end

return HandDisplay
