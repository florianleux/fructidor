
-- Fonction pour exécuter tous les tests
local function run_all_tests()
    -- Charger et exécuter tous les tests
    require("tests.structure.test_project_structure")
    require("tests.state.test_state_transitions")
    require("tests.garden.test_grid_coordinates")
    require("tests.game.test_turn_increment")
    require("tests.game.test_season_changes")
    require("tests.ui.test_ui_elements_position")
    require("tests.cards.test_card_attributes")
    require("tests.weather.test_dice_ranges")
    print("Tous les tests ont été exécutés.")
end

return {
    run_all_tests = run_all_tests
}
