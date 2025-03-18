-- Gestionnaire d'échelle pour adapter l'interface à différentes tailles d'écran
local ScaleManager = {}

-- Dimensions de référence pour la conception (1920x1080 HD)
ScaleManager.referenceWidth = 1920
ScaleManager.referenceHeight = 1080

-- Facteurs d'échelle calculés au démarrage
ScaleManager.scaleX = 1.0
ScaleManager.scaleY = 1.0
ScaleManager.scale = 1.0  -- Facteur d'échelle uniforme (min des deux)
ScaleManager.initialized = false

-- Initialisation du gestionnaire d'échelle
function ScaleManager.initialize()
    local width, height = love.graphics.getDimensions()
    
    -- Calculer les facteurs d'échelle
    ScaleManager.scaleX = width / ScaleManager.referenceWidth
    ScaleManager.scaleY = height / ScaleManager.referenceHeight
    
    -- Utiliser le facteur minimum pour une mise à l'échelle uniforme
    ScaleManager.scale = math.min(ScaleManager.scaleX, ScaleManager.scaleY)
    
    print("ScaleManager: Résolution détectée " .. width .. "x" .. height)
    print("ScaleManager: Échelle d'affichage: " .. ScaleManager.scale)
    
    ScaleManager.initialized = true
    return true
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
    return love.graphics.getWidth() / 2
end

-- Calcul de la position centrale verticale
function ScaleManager.getCenterY()
    return love.graphics.getHeight() / 2
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
    if not ScaleManager.initialized then
        print("AVERTISSEMENT: ScaleManager - Tentative de redimensionnement avant initialisation")
        return
    end
    
    -- Recalculer les facteurs d'échelle
    ScaleManager.scaleX = width / ScaleManager.referenceWidth
    ScaleManager.scaleY = height / ScaleManager.referenceHeight
    ScaleManager.scale = math.min(ScaleManager.scaleX, ScaleManager.scaleY)
    
    print("ScaleManager: Redimensionnement à " .. width .. "x" .. height .. " (échelle: " .. ScaleManager.scale .. ")")
end

return ScaleManager