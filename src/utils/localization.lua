-- Système de localisation pour Fructidor
local Constants = require('src.utils.constants')

local Localization = {}

-- Langue courante (par défaut: français)
Localization.currentLanguage = "fr"

-- Dictionnaires des traductions
Localization.translations = {
    ["fr"] = {
        -- Saisons
        [Constants.SEASON.SPRING] = "Printemps",
        [Constants.SEASON.SUMMER] = "Été",
        [Constants.SEASON.AUTUMN] = "Automne",
        [Constants.SEASON.WINTER] = "Hiver",
        
        -- Familles de plantes
        [Constants.PLANT_FAMILY.BRASSIKA] = "Brassika",
        [Constants.PLANT_FAMILY.SOLANA] = "Solana",
        [Constants.PLANT_FAMILY.FABA] = "Faba",
        [Constants.PLANT_FAMILY.KUKURBITA] = "Kukurbita",
        
        -- Stades de croissance
        [Constants.GROWTH_STAGE.SEED] = "Graine",
        [Constants.GROWTH_STAGE.PLANT] = "Plant",
        [Constants.GROWTH_STAGE.FRUITING] = "Fructifié",
        
        -- Types de cartes
        [Constants.CARD_TYPE.PLANT] = "Plante",
        [Constants.CARD_TYPE.OBJECT] = "Objet",
        
        -- Interface utilisateur
        ["ui.tour"] = "Tour",
        ["ui.saison"] = "Saison",
        ["ui.soleil"] = "Soleil",
        ["ui.pluie"] = "Pluie",
        ["ui.score"] = "Score",
        ["ui.fin_tour"] = "Fin du tour",
        ["ui.points"] = "pts"
    }
    -- Support pour d'autres langues à ajouter ici
}

-- Fonction pour obtenir la traduction d'une clé
function Localization.getText(key)
    local currentDict = Localization.translations[Localization.currentLanguage]
    
    if currentDict and currentDict[key] then
        return currentDict[key]
    end
    
    -- Retourne la clé si pas de traduction trouvée
    return tostring(key)
end

-- Fonction pour changer la langue courante
function Localization.setLanguage(languageCode)
    if Localization.translations[languageCode] then
        Localization.currentLanguage = languageCode
        return true
    end
    return false
end

return Localization