-- Composant Bouton
local UIComponent = require('src.ui.components.ui_component')

local Button = setmetatable({}, {__index = UIComponent})
Button.__index = Button

-- Constantes pour les états
Button.STATE = {
    NORMAL = "normal",
    HOVER = "hover",
    PRESSED = "pressed",
    DISABLED = "disabled"
}

-- Création d'un nouveau bouton
-- @param x Position X en pixels (basée sur résolution HD)
-- @param y Position Y en pixels (basée sur résolution HD)
-- @param width Largeur en pixels (basée sur résolution HD)
-- @param height Hauteur en pixels (basée sur résolution HD)
-- @param text Texte affiché sur le bouton
-- @param onClick Fonction appelée au clic
function Button.new(x, y, width, height, text, onClick)
    local self = setmetatable(UIComponent.new(x, y, width, height), Button)
    
    -- Propriétés du bouton
    self.text = text or ""
    self.onClick = onClick or function() end
    self.state = Button.STATE.NORMAL
    self.disabled = false
    
    -- Couleurs par état
    self.colors = {
        [Button.STATE.NORMAL] = {0.6, 0.8, 0.6, 1.0},
        [Button.STATE.HOVER] = {0.7, 0.9, 0.7, 1.0},
        [Button.STATE.PRESSED] = {0.5, 0.7, 0.5, 1.0},
        [Button.STATE.DISABLED] = {0.5, 0.5, 0.5, 0.7}
    }
    
    -- Couleurs du texte par état
    self.textColors = {
        [Button.STATE.NORMAL] = {0, 0, 0, 1.0},
        [Button.STATE.HOVER] = {0, 0, 0, 1.0},
        [Button.STATE.PRESSED] = {0, 0, 0, 1.0},
        [Button.STATE.DISABLED] = {0, 0, 0, 0.5}
    }
    
    -- Définir les dimensions du coin arrondi (pour rectangle avec coins arrondis)
    self.cornerRadius = 5 -- en pixels, sera mis à l'échelle
    
    return self
end

-- Activer/désactiver le bouton
function Button:setEnabled(enabled)
    self.disabled = not enabled
    if self.disabled then
        self.state = Button.STATE.DISABLED
    else
        self.state = Button.STATE.NORMAL
    end
end

-- Setter pour le texte
function Button:setText(text)
    self.text = text or ""
end

-- Mise à jour de l'état du bouton
function Button:update(dt)
    if self.disabled then
        return
    end
    
    -- Récupérer la position de la souris
    local mouseX, mouseY = love.mouse.getPosition()
    
    -- Vérifier si la souris est sur le bouton
    if self:contains(mouseX, mouseY) then
        if love.mouse.isDown(1) then
            self.state = Button.STATE.PRESSED
        else
            self.state = Button.STATE.HOVER
        end
    else
        self.state = Button.STATE.NORMAL
    end
end

-- Dessin du bouton
function Button:draw()
    if not self.visible then
        return
    end
    
    -- Couleur de fond selon l'état
    love.graphics.setColor(unpack(self.colors[self.state]))
    
    -- Dessiner le rectangle avec coins arrondis
    local scaledCornerRadius = self.cornerRadius * self.scale
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, scaledCornerRadius)
    
    -- Bordure
    love.graphics.setColor(0.4, 0.4, 0.4, self.alpha)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, scaledCornerRadius)
    
    -- Texte
    love.graphics.setColor(unpack(self.textColors[self.state]))
    
    -- Calculer la position du texte (centré)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.text, textX, textY)
    
    -- Restaurer la couleur
    love.graphics.setColor(1, 1, 1, 1)
end

-- Gestionnaire d'événements pour le clic
function Button:onEvent(event, x, y, button)
    if self.disabled or not self.visible then
        return false
    end
    
    if event == "mousepressed" and button == 1 and self:contains(x, y) then
        self.state = Button.STATE.PRESSED
        return true
    elseif event == "mousereleased" and button == 1 and self.state == Button.STATE.PRESSED then
        if self:contains(x, y) then
            self.onClick()
            self.state = Button.STATE.HOVER
            return true
        else
            self.state = Button.STATE.NORMAL
        end
    end
    
    return false
end

return Button