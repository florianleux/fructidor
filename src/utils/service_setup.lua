-- CE MODULE EST DÉPRÉCIÉ
-- Il est maintenu uniquement pour compatibilité rétroactive et sera supprimé dans une future version.
-- Utilisez l'injection de dépendances directe via les constructeurs à la place.

local warning = [[
ATTENTION: Le module ServiceSetup est déprécié.
Ce module sera supprimé dans une version future.
Utilisez l'injection de dépendances directe via les constructeurs à la place.
]]

print(warning)

-- Module stub simplifié pour la compatibilité
local ServiceSetup = {}

-- Fonction d'initialisation stub qui ne fait rien
function ServiceSetup.initialize()
    print(warning)
    return true
end

return ServiceSetup