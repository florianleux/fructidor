local GardenComponent = Class('GardenComponent')

function GardenComponent:initialize(garden)
    self.garden = garden or {
        width = 3,
        height = 2,
        grid = {},
        plantCount = 0
    }
    
    if not self.garden.grid then
        self.garden.grid = {}
        for y = 1, self.garden.height do
            self.garden.grid[y] = {}
        end
    end
end

function GardenComponent:getCell(x, y)
    if y < 1 or y > #self.garden.grid or x < 1 or not self.garden.grid[y][x] then
        return nil
    end
    
    return self.garden.grid[y][x]
end

return GardenComponent