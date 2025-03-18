-- Ce fichier est déprécié et sera supprimé.
-- Utilisez plutôt src.utils.service_setup pour l'initialisation des services.

-- Redirection vers le nouveau système
local ServiceSetup = require('src.utils.service_setup')

local DependencySetup = {
    initialize = function(systems)
        print("AVERTISSEMENT: L'utilisation de DependencySetup est dépréciée. Veuillez utiliser ServiceSetup à la place.")
        return ServiceSetup.initialize(systems)
    end
}

return DependencySetup