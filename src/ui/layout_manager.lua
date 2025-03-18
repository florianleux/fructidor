-- Gestionnaire de mise en page pour les composants UI avec positions absolues
local LayoutManager = {}
LayoutManager.__index = LayoutManager

function LayoutManager.new(params)
    local self = setmetatable({}, LayoutManager)
    
    -- Référence au gestionnaire d'échelle
    self.scaleManager = params.scaleManager
    
    -- Conteneurs principaux avec positions absolues
    self.containers = {
        -- Zone principale 
        main = {
            x = 0,                  -- Position absolue X
            y = 0,                  -- Position absolue Y
            width = self.scaleManager.referenceWidth,    -- Largeur absolue
            height = self.scaleManager.referenceHeight,  -- Hauteur absolue
            components = {}
        }
    }
    
    -- Recalculer immédiatement les limites
    self:recalculateBounds()
    
    return self
end

-- Calcule les dimensions de tous les conteneurs et leurs composants
function LayoutManager:recalculateBounds()
    -- Pour chaque conteneur, calculer les limites de ses composants
    for key, container in pairs(self.containers) do
        -- Ajuster les positions et dimensions du conteneur avec l'échelle
        local scaledX = container.x * self.scaleManager.scale
        local scaledY = container.y * self.scaleManager.scale
        local scaledWidth = container.width * self.scaleManager.scale
        local scaledHeight = container.height * self.scaleManager.scale
        
        -- Stocker les valeurs mises à l'échelle pour utilisation interne
        container.scaledX = scaledX
        container.scaledY = scaledY
        container.scaledWidth = scaledWidth
        container.scaledHeight = scaledHeight
        
        -- Calculer les limites de chaque composant dans ce conteneur
        for _, component in ipairs(container.components) do
            component:calculateBounds(
                container.x, container.y, 
                container.width, container.height
            )
        end
    end
end

-- Permet de positionner un conteneur à des coordonnées absolues
function LayoutManager:positionContainer(containerKey, x, y, width, height)
    if self.containers[containerKey] then
        local container = self.containers[containerKey]
        container.x = x
        container.y = y
        container.width = width
        container.height = height
        
        -- Recalculer immédiatement les limites
        self:recalculateBounds()
        
        return true
    end
    return false
end

-- Crée un nouveau conteneur avec des coordonnées absolues
function LayoutManager:createContainer(containerKey, x, y, width, height)
    if not self.containers[containerKey] then
        self.containers[containerKey] = {
            x = x or 0,
            y = y or 0,
            width = width or self.scaleManager.referenceWidth,
            height = height or self.scaleManager.referenceHeight,
            components = {}
        }
        
        -- Recalculer immédiatement les limites
        self:recalculateBounds()
        
        return true
    end
    return false
end

-- Ajoute un composant à un conteneur spécifique
function LayoutManager:addComponent(containerKey, component)
    if self.containers[containerKey] then
        table.insert(self.containers[containerKey].components, component)
        
        -- Calculer immédiatement les limites du nouveau composant
        local container = self.containers[containerKey]
        component:calculateBounds(
            container.x, container.y, 
            container.width, container.height
        )
        
        return true
    end
    return false
end

-- Dessine tous les composants de tous les conteneurs
function LayoutManager:draw()
    for _, container in pairs(self.containers) do
        for _, component in ipairs(container.components) do
            component:draw()
        end
    end
    
    -- Dessin de débogage des limites des conteneurs si demandé
    if love.keyboard.isDown("f4") then
        for key, container in pairs(self.containers) do
            love.graphics.setColor(0.2, 0.2, 0.8, 0.3)
            love.graphics.rectangle("fill", container.x, container.y, container.width, container.height)
            love.graphics.setColor(0.2, 0.2, 0.8, 0.7)
            love.graphics.rectangle("line", container.x, container.y, container.width, container.height)
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.print(key, container.x + 5, container.y + 5)
        end
    end
end

-- Met à jour tous les composants
function LayoutManager:update(dt)
    for _, container in pairs(self.containers) do
        for _, component in ipairs(container.components) do
            component:update(dt)
        end
    end
end

-- Transmet les événements souris aux composants
function LayoutManager:mousepressed(x, y, button)
    for _, container in pairs(self.containers) do
        for _, component in ipairs(container.components) do
            if component:containsPoint(x, y) then
                if component:mousepressed(x, y, button) then
                    return true  -- Événement consommé
                end
            end
        end
    end
    return false
end

function LayoutManager:mousereleased(x, y, button)
    for _, container in pairs(self.containers) do
        for _, component in ipairs(container.components) do
            if component:containsPoint(x, y) then
                if component:mousereleased(x, y, button) then
                    return true  -- Événement consommé
                end
            end
        end
    end
    return false
end

-- Trouve un composant par son ID
function LayoutManager:findComponentById(id)
    for _, container in pairs(self.containers) do
        for _, component in ipairs(container.components) do
            if component.id == id then
                return component
            end
        end
    end
    return nil
end

return LayoutManager
