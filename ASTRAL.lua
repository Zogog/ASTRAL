--========================================================--
--                  A S T R A L   H U B
--========================================================--

local ASTRAL = {
    Core = {},
    UI = {},
    Modules = {},
}

--========================================================--
--                 CORE MODULES
--========================================================--

ASTRAL.Core.AdoptMeAPI = require(script.Core.AdoptMeAPI)
ASTRAL.Core.Utils       = require(script.Core.Utils)
ASTRAL.Core.Pets        = require(script.Core.Pets)
ASTRAL.Core.Teleport    = require(script.Core.Teleport)
ASTRAL.Core.Ailments    = require(script.Core.Ailments)
ASTRAL.Core.Inventory   = require(script.Core.Inventory)
ASTRAL.Core.Movement    = require(script.Core.Movement)

--========================================================--
--                 UI MODULES
--========================================================--

ASTRAL.UI.RayfieldInit = require(script.UI.RayfieldInit)
ASTRAL.UI.Tabs         = require(script.UI.Tabs)
ASTRAL.UI.Dropdowns    = require(script.UI.Dropdowns)
ASTRAL.UI.Settings     = require(script.UI.Settings)

--========================================================--
--                 FEATURE MODULES
--========================================================--

ASTRAL.Modules.PetViewer   = require(script.Modules.PetViewer)
ASTRAL.Modules.TeleportHub = require(script.Modules.TeleportHub)
ASTRAL.Modules.AutoNeeds   = require(script.Modules.AutoNeeds)
ASTRAL.Modules.AutoPotions = require(script.Modules.AutoPotions)
ASTRAL.Modules.AutoEggs    = require(script.Modules.AutoEggs)
ASTRAL.Modules.BabyFarm    = require(script.Modules.BabyFarm)
ASTRAL.Modules.Webhooks    = require(script.Modules.Webhooks)

--========================================================--
--                 ASTRAL INITIALIZATION
--========================================================--

-- Create Rayfield window
local Window = ASTRAL.UI.RayfieldInit.Init()

-- Create tabs
local Tabs = ASTRAL.UI.Tabs.Create(Window)

-- Initialize all Core + Modules
for _, folder in pairs({ASTRAL.Core, ASTRAL.Modules}) do
    for name, module in pairs(folder) do
        if type(module) == "table" and module.Init then
            task.spawn(function()
                module.Init(Tabs, ASTRAL.Core.AdoptMeAPI)
            end)
        end
    end
end

print("ASTRAL Framework Loaded Successfully")

return ASTRAL
