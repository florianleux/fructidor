-- Gestionnaire d'échelle pour adapter l'interface à différentes tailles d'écran
local ScaleManager = {}

-- Dimensions de référence pour la conception (initialement 800x600)
ScaleManager.referenceWidth = 800
ScaleManager.referenceHeight = 600

-- Facteurs d'échelle calculés au démarrage
ScaleManager.scaleX = 1.0
ScaleManager.scaleY = 1.0
ScaleManager.scale = 1.0  -- Facteur d'échelle uniforme (min des deux)

-- Initialisation du gestionnaire d'échelle
function ScaleManager.initialize()
    -- Vérifier que love.graphics est disponible
    if not love.graphics then
        error("Le module love.graphics n'est pas disponible, impossible d'initialiser le ScaleManager")
        return
    end

    local width, height = love.graphics.getDimensions()
    
    -- Calculer les facteurs d'échelle
    ScaleManager.scaleX = width / ScaleManager.referenceWidth
    ScaleManager.scaleY = height / ScaleManager.referenceHeight
    
    -- Utiliser le facteur minimum pour une mise à l'échelle uniforme
    ScaleManager.scale = math.min(ScaleManager.scaleX, ScaleManager.scaleY)
    
    print("Échelle d'affichage: " .. ScaleManager.scale)
    print("Résolution: " .. width .. "x" .. height)
end

-- Mise à l'échelle d'une coordonnée X
function ScaleManager.scaleX(x)
    return x * ScaleManager.scaleX
end

-- Mise à l'échelle d'une coordonnée Y
function ScaleManager.scaleY(y)
    return y * ScaleManager.scaleY
end

-- Mise à l'échelle uniforme (utilisée pour les textes, images, etc.)
function ScaleManager.scaleUniform(value)
    return value * ScaleManager.scale
end

-- Application d'une transformation pour dessiner à l'échelle
function ScaleManager.applyScale()
    love.graphics.push()
    love.graphics.scale(ScaleManager.scale, ScaleManager.scale)
end

-- Restauration de la transformation d'origine
function ScaleManager.restoreScale()
    love.graphics.pop()
end

-- Calcul de la position centrale horizontale
function ScaleManager.getCenterX()
    local width = love.graphics.getWidth()
    return width / 2
end

-- Calcul de la position centrale verticale
function ScaleManager.getCenterY()
    local height = love.graphics.getHeight()
    return height / 2
end

-- Obtenir la région visible centrée
function ScaleManager.getVisibleArea()
    local width, height = love.graphics.getDimensions()
    local visibleWidth = ScaleManager.referenceWidth * ScaleManager.scale
    local visibleHeight = ScaleManager.referenceHeight * ScaleManager.scale
    
    -- Coordonnées du coin supérieur gauche de la zone visible
    local offsetX = (width - visibleWidth) / 2
    local offsetY = (height - visibleHeight) / 2
    
    return {
        x = offsetX,
        y = offsetY,
        width = visibleWidth,
        height = visibleHeight
    }
end

-- Fonction pour redimensionner la fenêtre avec un rapport d'aspect constant
function ScaleManager.resizeWindow(width, height)
    -- Recalculer les facteurs d'échelle
    ScaleManager.scaleX = width / ScaleManager.referenceWidth
    ScaleManager.scaleY = height / ScaleManager.referenceHeight
    ScaleManager.scale = math.min(ScaleManager.scaleX, ScaleManager.scaleY)
    
    print("Fenêtre redimensionnée: " .. width .. "x" .. height)
    print("Nouvelle échelle: " .. ScaleManager.scale)
end

return ScaleManager