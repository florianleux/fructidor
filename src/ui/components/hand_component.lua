-- Composant unifié d'affichage de la main du joueur
-- Suit le modèle d'architecture KISS à deux niveaux
local ComponentBase = require('src.ui.components.component_base')

local HandComponent = setmetatable({}, {__index = ComponentBase})
HandComponent.__index = HandComponent

function HandComponent.new(params)
    local self = setmetatable(ComponentBase.new(params), HandComponent)
    
    -- Modèle associé (cardSystem)
    self.model = params.cardSystem
    
    -- Alias pour faciliter la transition du code existant
    self.cardSystem = self.model
    
    -- Dépendances
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

function HandComponent:draw()
    if not self.visible then return end
    
    -- Dessiner le fond
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Debug: afficher la référence au cardSystem
    print("HandComponent:draw() - self.cardSystem: " .. tostring(self.cardSystem))
    
    -- Récupérer les cartes en main depuis le système de cartes
    local hand = self.cardSystem and self.cardSystem:getHand() or {}
    
    -- Debug: afficher le nombre de cartes
    print("HandComponent: " .. #hand .. " cartes en main")
    
    -- Si aucune carte, afficher un message
    if #hand == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.print("Main vide", self.x + self.width/2 - 30, self.y + self.height/2 - 10)
        return
    end
    
    -- Calculer les positions des cartes en disposition en arc
    local cardSpacing = math.min(self.cardWidth + 10, self.width / (#hand + 1))
    local totalWidth = cardSpacing * (#hand - 1) + self.cardWidth
    local startX = self.x + (self.width - totalWidth) / 2
    local baseY = self.y + self.height - self.cardHeight - 20  -- Positionnement en bas
    
    -- Valeurs d'élévation pour l'arc
    local maxElevation = 40
    
    -- Réinitialiser les positions des cartes
    self.cardPositions = {}
    
    -- Dessiner chaque carte
    for i, card in ipairs(hand) do
        -- Debug: afficher informations sur chaque carte
        print("Carte " .. i .. ": " .. (card.name or "sans nom") .. ", type: " .. tostring(card.type))
        
        -- Calculer la position de la carte sur un arc
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
            
            -- Stocker les positions pour mettre à jour la position de la carte dans le CardSystem 
            -- (pour les futures interactions)
            card.x = cardX + self.cardWidth/2  -- Centrer la position
            card.y = cardY + self.cardHeight/2
        end
    end
end

function HandComponent:drawCard(card, x, y, rotation, isHovered)
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
        
        -- Symbole de couleur
        local colorName = card.color or "Green"
        local colorValue = self.colors["color"..colorName] or self.colors.cardText
        love.graphics.setColor(unpack(colorValue))
        love.graphics.rectangle("fill", self.cardWidth - 15, 5, 10, 10)
        
        -- Dessiner un symbole pour la plante
        love.graphics.setColor(0.3, 0.7, 0.3)
        love.graphics.rectangle("fill", 10, 40, self.cardWidth - 20, 20)
        
        -- Afficher les besoins de la plante
        love.graphics.setColor(unpack(self.colors.cardText))
        love.graphics.print("\226\152\128\239\184\143" .. (card.sunToSprout or "?"), 10, 70, 0, 0.6, 0.6)
        love.graphics.print("\240\159\140\167\239\184\143" .. (card.rainToSprout or "?"), 10, 85, 0, 0.6, 0.6)
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

function HandComponent:update(dt)
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

function HandComponent:mousepressed(x, y, button)
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

-- Méthode pour rafraîchir l'affichage quand la main change
function HandComponent:refreshHand()
    -- Cette méthode peut être appelée quand la main du joueur change
    -- mais n'a pas besoin d'implémentation spécifique car les données
    -- sont récupérées directement depuis le cardSystem à chaque frame
    print("refreshHand() appelé")
    
    -- Debug: afficher la référence au cardSystem
    if self.cardSystem then
        print("HandComponent:refreshHand - cardSystem présent, cartes: " .. #self.cardSystem:getHand())
    else
        print("HandComponent:refreshHand - cardSystem absent!")
    end
end

return HandComponent