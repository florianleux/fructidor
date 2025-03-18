-- Ce fichier est maintenu uniquement pour compatibilité
-- et sera supprimé dans une version future.
--
-- AVIS IMPORTANT: Ce module est déprécié et ne doit plus être utilisé.
-- Utilisez l'injection de dépendances directe à la place.

local warning = [[
ATTENTION: Le module Services est déprécié.
Utilisez l'injection de dépendances directe via les constructeurs à la place.
]]

print(warning)

-- Stub minimal pour éviter les erreurs dans le code existant
local Services = {
    _services = {},
    initialized = false
}

function Services.get()
    print(warning)
    return nil
end

function Services.initialize()
    print(warning)
    return true
end

return Services