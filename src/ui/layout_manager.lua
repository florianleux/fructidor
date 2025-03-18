-- Gestionnaire de mise en page simplifié pour les composants d'interface
local LayoutManager = {}
LayoutManager.__index = LayoutManager

function LayoutManager.new(params)
    local self = setmetatable({}, LayoutManager)
    
    -- Stocker les dépendances
    self.scaleManager = params.scaleManager
    
    -- Structure de données simplifiée pour les composants
    self.components = {
        main = {}, -- écran principal du jeu
        hub = {},  -- écran du hub entre les runs
        menu = {}  -- menu principal (prévu pour l'avenir)
    }
    
    -- Écran actuel
    self.currentScreen = "main"
    
    return self
end

function LayoutManager:addComponent(screenName, component)
    -- Vérifier que l'écran existe
    if not self.components[screenName] then
        self.components[screenName] = {}
    end
    
    -- Ajouter le composant
    table.insert(self.components[screenName], component)
end

function LayoutManager:removeComponent(screenName, component)
    -- Vérifier que l'écran existe
    if not self.components[screenName] then
        return
    end
    
    -- Chercher et supprimer le composant
    for i, comp in ipairs(self.components[screenName]) do
        if comp == component then
            table.remove(self.components[screenName], i)
            return
        end
    end
end

function LayoutManager:switchScreen(screenName)
    -- Vérifier que l'écran existe
    if self.components[screenName] then
        self.currentScreen = screenName
    else
        print("ERREUR: Tentative de passage à un écran inexistant: " .. screenName)
    end
end

function LayoutManager:update(dt)
    -- Mettre à jour tous les composants de l'écran actuel
    for _, component in ipairs(self.components[self.currentScreen]) do
        if component.update then
            component:update(dt)
        end
    end
end

function LayoutManager:draw()
    -- Dessiner tous les composants de l'écran actuel
    for _, component in ipairs(self.components[self.currentScreen]) do
        if component.draw then
            component:draw()
        end
    end
end

function LayoutManager:mousepressed(x, y, button)
    -- Parcourir les composants dans l'ordre inverse pour priorité au premier plan
    local handled = false
    
    for i = #self.components[self.currentScreen], 1, -1 do
        local component = self.components[self.currentScreen][i]
        
        if component.mousepressed and component:isPointInside(x, y) then
            local result = component:mousepressed(x, y, button)
            if result then
                handled = true
                break
            end
        end
    end
    
    return handled
end

function LayoutManager:mousereleased(x, y, button)
    -- Similaire à mousepressed
    local handled = false
    
    for i = #self.components[self.currentScreen], 1, -1 do
        local component = self.components[self.currentScreen][i]
        
        if component.mousereleased and component:isPointInside(x, y) then
            local result = component:mousereleased(x, y, button)
            if result then
                handled = true
                break
            end
        end
    end
    
    return handled
end

function LayoutManager:mousemoved(x, y, dx, dy)
    -- Transmettre les mouvements de la souris aux composants
    local handled = false
    
    for i = #self.components[self.currentScreen], 1, -1 do
        local component = self.components[self.currentScreen][i]
        
        if component.mousemoved then
            local result = component:mousemoved(x, y, dx, dy)
            if result then
                handled = true
                break
            end
        end
    end
    
    return handled
end

return LayoutManager