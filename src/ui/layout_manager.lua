-- Gestionnaire de mise en page pour les composants UI
local LayoutManager = {}
LayoutManager.__index = LayoutManager

function LayoutManager.new(params)
    local self = setmetatable({}, LayoutManager)
    
    -- Référence au gestionnaire d'échelle
    self.scaleManager = params.scaleManager
    
    -- Conteneurs principaux
    self.containers = {
        -- Un seul conteneur main qui occupe toute la fenêtre
        main = {
            relX = 0,
            relY = 0,
            relWidth = 1,     -- 100% de la largeur au lieu de 75%
            relHeight = 1,
            components = {}
        }
        -- La sidebar a été supprimée
    }
    
    -- Positions et dimensions absolues calculées
    self.x = 0
    self.y = 0
    self.width = self.scaleManager.referenceWidth
    self.height = self.scaleManager.referenceHeight
    
    -- Recalculer immédiatement les limites
    self:recalculateBounds()
    
    return self
end

-- Calcule les dimensions de tous les conteneurs et leurs composants
function LayoutManager:recalculateBounds()
    -- Mettre à jour les dimensions globales
    self.width = self.scaleManager.referenceWidth
    self.height = self.scaleManager.referenceHeight
    
    -- Calculer les limites de chaque conteneur
    for key, container in pairs(self.containers) do
        container.x = self.x + (self.width * container.relX)
        container.y = self.y + (self.height * container.relY)
        container.width = self.width * container.relWidth
        container.height = self.height * container.relHeight
        
        -- Calculer les limites de chaque composant dans ce conteneur
        for _, component in ipairs(container.components) do
            component:calculateBounds(
                container.x, container.y, 
                container.width, container.height
            )
        end
    end
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
