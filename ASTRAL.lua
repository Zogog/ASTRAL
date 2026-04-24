--========================================================--
--                  A S T R A L   H U B
--========================================================--
warn("ASTRAL GITHUB VERSION LOADED")


local REPO = "https://raw.githubusercontent.com/Zogog/ASTRAL/refs/heads/main/"

local function import(path)
    return loadstring(game:HttpGet(REPO .. path))()
end

local ASTRAL = {
    Core = {},
    UI = {},
    Modules = {},
}

--========================================================--
--                 CORE MODULES
--========================================================--

ASTRAL.Core.AdoptMeAPI = import("Core/AdoptMeAPI.lua")
ASTRAL.Core.Utils       = import("Core/Utils.lua")
ASTRAL.Core.Pets        = import("Core/Pets.lua")
ASTRAL.Core.Teleport    = import("Core/Teleport.lua")
ASTRAL.Core.Ailments    = import("Core/Ailments.lua")
ASTRAL.Core.Inventory   = import("Core/Inventory.lua")
ASTRAL.Core.Movement    = import("Core/Movement.lua")

--========================================================--
--                 UI MODULES
--========================================================--

ASTRAL.UI.RayfieldInit = import("UI/RayfieldInit.lua")
ASTRAL.UI.Tabs         = import("UI/Tabs.lua")
ASTRAL.UI.Dropdowns    = import("UI/Dropdowns.lua")
ASTRAL.UI.Settings     = import("UI/Settings.lua")

--========================================================--
--                 FEATURE MODULES
--========================================================--

ASTRAL.Modules.PetViewer   = import("Modules/PetViewer.lua")
ASTRAL.Modules.TeleportHub = import("Modules/TeleportHub.lua")
ASTRAL.Modules.AutoNeeds   = import("Modules/AutoNeeds.lua")
ASTRAL.Modules.AutoPotions = import("Modules/AutoPotions.lua")
ASTRAL.Modules.AutoEggs    = import("Modules/AutoEggs.lua")
ASTRAL.Modules.BabyFarm    = import("Modules/BabyFarm.lua")
ASTRAL.Modules.Webhooks    = import("Modules/Webhooks.lua")

--========================================================--
--                 ASTRAL INITIALIZATION
--========================================================--

local Window = ASTRAL.UI.RayfieldInit.Init()
local Tabs = ASTRAL.UI.Tabs.Create(Window)

for _, folder in pairs({ASTRAL.Modules}) do
    for name, module in pairs(folder) do
        if type(module) == "table" and module.Init then
            task.spawn(function()
                module.Init(Tabs, ASTRAL.Core, ASTRAL.UI)
            end)
        end
    end
end

print("ASTRAL Framework Loaded Successfully (GitHub Version)")

return ASTRAL
