
local describe = require("busted").describe
local it = require("busted").it
local assert = require("busted").assert

describe("Structure du projet", function()
  
  it("vérifie que tous les dossiers nécessaires existent", function()
    local directories = {
      "src",
      "src/entities",
      "src/states",
      "src/systems",
      "src/ui",
      "src/utils",
      "assets",
      "assets/graphics",
      "assets/sounds",
      "assets/fonts",
      "assets/data",
      "lib",
      "tests"
    }
    
    for _, dir in ipairs(directories) do
      local info = love.filesystem.getInfo(dir)
      assert.is_not_nil(info, "Le dossier " .. dir .. " n'existe pas")
      assert.equals("directory", info.type, dir .. " n'est pas un dossier")
    end
  end)
  
  it("vérifie que les fichiers essentiels existent", function()
    local files = {
      "main.lua",
      "conf.lua"
    }
    
    for _, file in ipairs(files) do
      local info = love.filesystem.getInfo(file)
      assert.is_not_nil(info, "Le fichier " .. file .. " n'existe pas")
      assert.equals("file", info.type, file .. " n'est pas un fichier")
    end
  end)
  
  it("vérifie la structure des modules de base", function()
    local modules = {
      "src/entities/garden",
      "src/systems/card_system",
      "src/ui/drag_drop"
    }
    
    for _, module in ipairs(modules) do
      local success = pcall(function() return require(module) end)
      assert.is_true(success, "Impossible de charger le module " .. module)
    end
  end)
end)
