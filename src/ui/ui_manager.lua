-- Gestionnaire d'interface utilisateur
local UIComponent = require('src.ui.components.ui_component')
local Button = require('src.ui.components.button')
local Card = require('src.ui.components.card')
local ScaleManager = require('src.utils.scale_manager')

local UIManager = {}

-- Liste des composants gérés
UIManager.components = {}

-- Initialiser le UIManager
function UIManager.initialize()
    UIManager.components = {}
    return true
end

-- Ajouter un composant
function UIManager.addComponent(component, id)
    if not component or not component.updateScale then
        print("ERREUR: UIManager - Tentative d'ajout d'un objet qui n'est pas un UIComponent")
        return nil
    end
    
    id = id or "component_" .. tostring(#UIManager.components + 1)
    component.id = id
    UIManager.components[id] = component
    return component
end

-- Créer et ajouter un bouton
function UIManager.createButton(x, y, width, height, text, onClick, id)
    local button = Button.new(x, y, width, height, text, onClick)
    return UIManager.addComponent(button, id)
end

-- Créer et ajouter une carte
function UIManager.createCard(x, y, data, id)
    local card = Card.new(x, y, data)
    return UIManager.addComponent(card, id)
end

-- Récupérer un composant par ID
function UIManager.getComponent(id)
    return UIManager.components[id]
end

-- Supprimer un composant
function UIManager.removeComponent(id)
    if type(id) == "table" and id.id then
        id = id.id
    end
    UIManager.components[id] = nil
end

-- Mettre à jour tous les composants
function UIManager.update(dt)
    for id, component in pairs(UIManager.components) do
        component:update(dt)
    end
end

-- Dessiner tous les composants
function UIManager.draw()
    -- Appliquer l'échelle globale
    ScaleManager.applyScale()
    
    for id, component in pairs(UIManager.components) do
        component:draw()
    end
    
    -- Restaurer l'échelle
    ScaleManager.restoreScale()
end

-- Mettre à jour l'échelle de tous les composants
function UIManager.updateScale()
    for id, component in pairs(UIManager.components) do
        component:updateScale()
    end
end

-- Gérer les événements d'entrée
function UIManager.handleEvent(event, x, y, ...)
    -- Ajuster les coordonnées à l'échelle
    local scaledX, scaledY
    if ScaleManager.initialized then
        scaledX = x / ScaleManager.scale
        scaledY = y / ScaleManager.scale
    else
        scaledX = x
        scaledY = y
    end
    
    -- Parcourir les composants de haut en bas (ordre d'affichage inversé)
    local componentIds = {}
    for id, _ in pairs(UIManager.components) do
        table.insert(componentIds, id)
    end
    
    -- Traiter d'abord les événements pour les composants au premier plan
    for i = #componentIds, 1, -1 do
        local id = componentIds[i]
        local component = UIManager.components[id]
        
        if component and component.visible and component.onEvent then
            local handled = component:onEvent(event, scaledX, scaledY, ...)
            if handled then
                return true
            end
        end
    end
    
    return false
end

-- Réinitialiser tous les composants
function UIManager.reset()
    UIManager.components = {}
end

return UIManager