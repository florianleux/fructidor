local PlantComponent = Class('PlantComponent')

function PlantComponent:initialize(plant)
    self.plant = plant or {
        growthStage = "seed",
        accumulatedSun = 0,
        accumulatedRain = 0
    }
end

return PlantComponent