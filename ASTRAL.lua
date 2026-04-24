--========================================================--
--                  A S T R A L   H U B
--========================================================--

local ASTRAL = {
    Core = {},
    UI = {},
    Modules = {},
}

--========================================================--
--                 INTERNAL MODULE LOADER
--========================================================--

local function LoadModule(source)
    local fn = loadstring(source)
    return fn()
end

--========================================================--
--                 CORE MODULES (EMPTY)
--========================================================--

ASTRAL.Core.AdoptMeAPI = LoadModule([[
    -- AdoptMeAPI Backend Wrapper
    -- Paste your AdoptMeAPI.txt content inside this module later

    local API = {}

    function API.Init()
        -- placeholder
    end

    return API
]])

ASTRAL.Core.Utils = LoadModule([[
    local Utils = {}

    function Utils.NaturalSort(a, b)
        local function pad(n) return ("%09d"):format(tonumber(n) or 0) end
        a = a:gsub("(%d+)", pad)
        b = b:gsub("(%d+)", pad)
        return a < b
    end

    function Utils.FirstSix(str)
        return string.sub(str, 1, 6)
    end

    function Utils.IsLetters(str)
        return str:match("^[A-Za-z]+$") ~= nil
    end

    return Utils
]])

ASTRAL.Core.Pets = LoadModule([[
    local Pets = {}

    function Pets.Init()
        -- placeholder
    end

    return Pets
]])

ASTRAL.Core.Teleport = LoadModule([[
    local Teleport = {}

    function Teleport.Init()
        -- placeholder
    end

    return Teleport
]])

ASTRAL.Core.Ailments = LoadModule([[
    local Ailments = {}

    function Ailments.Init()
        -- placeholder
    end

    return Ailments
]])

ASTRAL.Core.Inventory = LoadModule([[
    local Inventory = {}

    function Inventory.Init()
        -- placeholder
    end

    return Inventory
]])

ASTRAL.Core.Movement = LoadModule([[
    local Movement = {}

    function Movement.Init()
        -- placeholder
    end

    return Movement
]])

--========================================================--
--                 UI MODULES (EMPTY)
--========================================================--

ASTRAL.UI.RayfieldInit = LoadModule([[
    local UI = {}

    function UI.Init()
        local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

        local Window = Rayfield:CreateWindow({
            Name = "ASTRAL Hub",
            LoadingTitle = "ASTRAL",
            LoadingSubtitle = "Initializing...",
            Theme = "Default",
            DisableRayfieldPrompts = true,
        })

        return Window
    end

    return UI
]])

ASTRAL.UI.Tabs = LoadModule([[
    local Tabs = {}

    function Tabs.Create(Window)
        return {
            Main = Window:CreateTab("Main", "home"),
            Pets = Window:CreateTab("Pets", "paw-print"),
            Teleports = Window:CreateTab("Teleports", "map"),
            Autofarm = Window:CreateTab("Autofarm", "sparkles"),
            Misc = Window:CreateTab("Misc", "settings"),
        }
    end

    return Tabs
]])

--========================================================--
--                 FEATURE MODULES (EMPTY)
--========================================================--

ASTRAL.Modules.PetViewer = LoadModule([[
    local M = {}

    function M.Init(Tabs, API)
        -- placeholder
    end

    return M
]])

ASTRAL.Modules.TeleportHub = LoadModule([[
    local M = {}

    function M.Init(Tabs, API)
        -- placeholder
    end

    return M
]])

ASTRAL.Modules.AutoNeeds = LoadModule([[
    local M = {}

    function M.Init(Tabs, API)
        -- placeholder
    end

    return M
]])

ASTRAL.Modules.AutoPotions = LoadModule([[
    local M = {}

    function M.Init(Tabs, API)
        -- placeholder
    end

    return M
]])

ASTRAL.Modules.AutoEggs = LoadModule([[
    local M = {}

    function M.Init(Tabs, API)
        -- placeholder
    end

    return M
]])

ASTRAL.Modules.BabyFarm = LoadModule([[
    local M = {}

    function M.Init(Tabs, API)
        -- placeholder
    end

    return M
]])

ASTRAL.Modules.Webhooks = LoadModule([[
    local M = {}

    function M.Init(Tabs, API)
        -- placeholder
    end

    return M
]])

--========================================================--
--                 ASTRAL INITIALIZATION
--========================================================--

local Window = ASTRAL.UI.RayfieldInit.Init()
local Tabs = ASTRAL.UI.Tabs.Create(Window)

-- Initialize all modules
for _, folder in pairs({ASTRAL.Core, ASTRAL.Modules}) do
    for name, module in pairs(folder) do
        if type(module) == "table" and module.Init then
            module.Init(Tabs, ASTRAL.Core.AdoptMeAPI)
        end
    end
end

print("ASTRAL Framework Loaded Successfully")

return ASTRAL
