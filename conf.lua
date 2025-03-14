
-- Configuration LÖVE

function love.conf(t)
    t.identity = "fructidor"           -- Nom pour le stockage du jeu
    t.version = "11.4"                 -- Version de LÖVE
    t.console = true                   -- Attacher une console (debug)
    
    t.window.title = "Fructidor"       -- Titre de la fenêtre
    t.window.icon = nil                -- À remplacer par un chemin vers l'icône
    t.window.width = 800               -- Largeur de la fenêtre
    t.window.height = 600              -- Hauteur de la fenêtre
    t.window.minwidth = 800            -- Largeur minimale de la fenêtre (redimensionnable)
    t.window.minheight = 600           -- Hauteur minimale de la fenêtre (redimensionnable)
    t.window.resizable = true          -- La fenêtre peut être redimensionnée
    t.window.vsync = 1                 -- Activer la synchro verticale
    
    -- Les modules dont nous avons besoin
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
    
    -- Variables personnalisées
    t.externalStorage = true           -- Pour l'accès aux fichiers
    
    -- Pour le mode test
    t.testing = false                  -- Par défaut, pas en mode test
end

-- Interception des arguments pour activer le mode test
if arg and arg[2] == "--test" then
    local oldConf = love.conf
    love.conf = function(t)
        oldConf(t)
        t.testing = true
        print("Mode test activé")
    end
end
