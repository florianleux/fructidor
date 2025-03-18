-- constants.lua
-- Définition des constantes pour l'interface utilisateur basée sur les pixels
-- Les valeurs sont basées sur une résolution de référence HD (1920x1080)

local constants = {}

-- Résolution de référence pour le développement (déjà définie dans ScaleManager)
constants.REFERENCE_WIDTH = 1920
constants.REFERENCE_HEIGHT = 1080

-- Marges et espacements standards
constants.UI_MARGIN = 10     -- Marge générale de l'interface
constants.UI_PADDING = 20    -- Espacement interne des éléments
constants.CORNER_RADIUS = 5  -- Rayon des coins arrondis standard

-- Dimensions des zones principales de l'écran
constants.HEADER_HEIGHT = 40                        -- Hauteur de la barre de titre
constants.TURN_INDICATOR_HEIGHT = 30                -- Hauteur de l'indicateur de tour
constants.WEATHER_SECTION_HEIGHT = 50               -- Hauteur de la section météo
constants.GARDEN_TOP_MARGIN = 160                   -- Marge supérieure du potager
constants.CELL_SIZE = 70                            -- Taille d'une cellule du potager
constants.MAIN_PANEL_WIDTH = 1440                   -- 3/4 de la largeur totale (pour layout principal)
constants.INFO_PANEL_WIDTH = 480                    -- 1/4 de la largeur totale (pour colonne info)

-- Dimensions des éléments interactifs
constants.DIE_SIZE = 40                             -- Taille des dés météo
constants.DIE_CORNER_RADIUS = 6                     -- Rayon des coins arrondis des dés
constants.BUTTON_WIDTH = 80                         -- Largeur standard des boutons
constants.BUTTON_HEIGHT = 30                        -- Hauteur standard des boutons

-- Dimensions des cartes
constants.CARD_WIDTH = 108                          -- Largeur d'une carte
constants.CARD_HEIGHT = 180                         -- Hauteur d'une carte
constants.CARD_CORNER_RADIUS = 5                    -- Rayon des coins arrondis des cartes
constants.CARD_HEADER_HEIGHT = 27                   -- Hauteur de l'en-tête d'une carte
constants.CARD_TEXT_PADDING_X = 10                  -- Marge horizontale du texte dans une carte
constants.CARD_TEXT_LINE_HEIGHT = 18                -- Hauteur de ligne du texte dans une carte
constants.CARD_SCALE_WHEN_DRAGGED = 0.6             -- Taille réduite pour le drag & drop

-- Constantes d'animation
constants.DRAG_ANIMATION_DURATION = 0.3             -- Durée de l'animation de drag en secondes
constants.RETURN_ANIMATION_DURATION = 0.3           -- Durée de l'animation de retour en main

-- Autres constantes
constants.TEXT_SCALE = 1.0                          -- Échelle de base du texte (sera ajustée par ScaleManager)

return constants
