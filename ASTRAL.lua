--========================================================--
--                     A S T R A L
--        Cleaned Loader + PetViewer + Extras
--========================================================--

local ASTRAL = {}
ASTRAL.Core = {}
ASTRAL.Modules = {}

--========================================================--
-- Safe Import
--========================================================--

local function safeImport(path)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(ASTRAL.REPO .. path))()
    end)

    if not ok then
        warn("[ASTRAL SafeMode] Failed to load module:", path)
        warn("Error:", result)
        return nil
    end

    return result
end

--========================================================--
-- Repo Root
--========================================================--

ASTRAL.REPO = "https://raw.githubusercontent.com/Zogog/ASTRAL/main/"

--========================================================--
-- Load Core Modules
--========================================================--

ASTRAL.Core.AdoptMeAPI = safeImport("Core/AdoptMeAPI.lua")
ASTRAL.Core.Movement   = safeImport("Core/Movement.lua")
ASTRAL.Core.Ailments   = safeImport("Core/Ailments.lua")
ASTRAL.Core.Pets       = safeImport("Core/Pets.lua")

--========================================================--
-- Load UI Framework
--========================================================--

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

ASTRAL.UI = {}
ASTRAL.UI.Window = Rayfield:CreateWindow({
    Name = "ASTRAL Hub",
    Icon = 116531676650470,
    LoadingTitle = "ASTRAL Framework",
    LoadingSubtitle = "Initializing...",
    Theme = "Default",
    DisableRayfieldPrompts = true,
})

--========================================================--
-- Create Tabs
--========================================================--

local Tabs = {}

Tabs.Main       = ASTRAL.UI.Window:CreateTab("Main", "home")
Tabs.Pets       = ASTRAL.UI.Window:CreateTab("Pets", "paw-print")
Tabs.Extras     = ASTRAL.UI.Window:CreateTab("Extras", "settings") -- NEW TAB
Tabs.Teleports  = ASTRAL.UI.Window:CreateTab("Teleports", "map")
Tabs.Autofarm   = ASTRAL.UI.Window:CreateTab("Autofarm", "zap")

ASTRAL.Tabs = Tabs

--========================================================--
-- Load Modules
--========================================================--

ASTRAL.Modules.Main        = safeImport("Modules/Main.lua")
ASTRAL.Modules.AutoNeeds   = safeImport("Modules/AutoNeeds.lua")
ASTRAL.Modules.TeleportHub = safeImport("Modules/TeleportHub.lua")
ASTRAL.Modules.PetViewer   = safeImport("Modules/PetViewer.lua")
ASTRAL.Modules.Extras      = safeImport("Modules/Extras.lua") -- NEW

--========================================================--
-- Initialize Modules
--========================================================--

local function initModule(name, module)
    if not module then return end

    local ok, err = pcall(function()
        module.Init(Tabs, ASTRAL.Core, ASTRAL.UI)
    end)

    if ok then
        print("[ASTRAL] Module initialized:", name)
    else
        warn("⚠️ [ASTRAL SafeMode] Init failed for module:", name)
        warn("Error:", err)
    end
end

initModule("Main",        ASTRAL.Modules.Main)
initModule("AutoNeeds",   ASTRAL.Modules.AutoNeeds)
initModule("TeleportHub", ASTRAL.Modules.TeleportHub)
initModule("PetViewer",   ASTRAL.Modules.PetViewer)
initModule("Extras",      ASTRAL.Modules.Extras) -- NEW

--========================================================--
-- Final Message
--========================================================--

print("ASTRAL Framework Loaded Successfully (Clean Edition + PetViewer + Extras)")

return ASTRAL
