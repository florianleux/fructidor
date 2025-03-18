-- Système de localisation pour Fructidor
local Constants = require('src.utils.constants')

local Localization = {}

-- Langue courante (par défaut: français)
Localization.currentLanguage = "fr"

-- Cache des traductions pour éviter des recherches répétées
Localization.cache = {}

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
        
        -- Stades de croissance (mise à jour avec les nouvelles constantes)
        [Constants.GROWTH_STAGE.SEED] = "Graine",
        [Constants.GROWTH_STAGE.SPROUT] = "Plant",
        [Constants.GROWTH_STAGE.FRUIT] = "Fructifié",
        
        -- Types de cartes
        [Constants.CARD_TYPE.PLANT] = "Plante",
        [Constants.CARD_TYPE.OBJECT] = "Objet",
        
        -- Interface utilisateur
        ["ui.tour"] = "Tour",
        ["ui.saison"] = "Saison",
        ["ui.saison_numero"] = "Saison", 
        ["ui.soleil"] = "Soleil",
        ["ui.pluie"] = "Pluie",
        ["ui.score"] = "Score",
        ["ui.score_title"] = "Score",
        ["ui.fin_tour"] = "Fin du tour",
        ["ui.points"] = "pts",
        ["ui.florins"] = "Florins",
        
        -- Textes d'erreur et d'information
        ["error.dependency_not_found"] = "Dépendance non trouvée",
        ["error.initialization_failed"] = "Échec d'initialisation",
        ["info.turn_completed"] = "Tour terminé",
        ["info.loading"] = "Chargement en cours...",
        
        -- Nom des saisons au format numérique
        ["season.1"] = "Printemps",
        ["season.2"] = "Été",
        ["season.3"] = "Automne",
        ["season.4"] = "Hiver"
    }
    -- Support pour d'autres langues à ajouter ici
}

-- Fonction pour obtenir la traduction d'une clé
function Localization.getText(key)
    -- Vérifier si la traduction est en cache
    local cacheKey = Localization.currentLanguage .. "_" .. tostring(key)
    if Localization.cache[cacheKey] then
        return Localization.cache[cacheKey]
    end
    
    local currentDict = Localization.translations[Localization.currentLanguage]
    
    if currentDict and currentDict[key] then
        -- Mettre en cache pour accès futur
        Localization.cache[cacheKey] = currentDict[key]
        return currentDict[key]
    end
    
    -- Retourne la clé si pas de traduction trouvée
    return tostring(key)
end

-- Fonction pour changer la langue courante
function Localization.setLanguage(languageCode)
    if Localization.translations[languageCode] then
        Localization.currentLanguage = languageCode
        -- Vider le cache lors d'un changement de langue
        Localization.cache = {}
        return true
    end
    return false
end

-- Fonction pour réinitialiser le cache (utile lors de changements dynamiques)
function Localization.clearCache()
    Localization.cache = {}
end

return Localization