--========================================================--
--                  A S T R A L   H U B
--                SafeMode + Crash Protection
--========================================================--

warn("ASTRAL GITHUB VERSION LOADED (SafeMode Enabled)")

local REPO = "https://raw.githubusercontent.com/Zogog/ASTRAL/main/"

local function safeImport(path)
    local url = REPO .. path

    -- Step 1: Download
    local okHttp, code = pcall(function()
        return game:HttpGet(url)
    end)

    if not okHttp then
        warn("[ASTRAL SafeMode] Failed to download:", path, code)
        return nil
    end

    -- Step 2: Compile
    local fn, err = loadstring(code)
    if not fn then
        warn("[ASTRAL SafeMode] loadstring failed:", path, err)
        return nil
    end

    -- Step 3: Execute
    local okRun, module = pcall(fn)
    if not okRun then
        warn("[ASTRAL SafeMode] Module runtime error:", path, module)
        return nil
    end

    -- Step 4: Validate
    if type(module) ~= "table" then
        warn("[ASTRAL SafeMode] Module returned non-table:", path)
        return nil
    end

    print("[ASTRAL] Loaded:", path)
    return module
end

local ASTRAL = {
    Core    = {},
    UI      = {},
    Modules = {},
    SafeMode = true,
}

--========================================================--
--                 CORE MODULES
--========================================================--

ASTRAL.Core.AdoptMeAPI = safeImport("Core/AdoptMeAPI.lua")
ASTRAL.Core.Utils      = safeImport("Core/Utils.lua")
ASTRAL.Core.Pets       = safeImport("Core/Pets.lua")
ASTRAL.Core.Teleport   = safeImport("Core/Teleport.lua")
ASTRAL.Core.Ailments   = safeImport("Core/Ailments.lua")
ASTRAL.Core.Inventory  = safeImport("Core/Inventory.lua")
ASTRAL.Core.Movement   = safeImport("Core/Movement.lua")

--========================================================--
--                 UI MODULES
--========================================================--

ASTRAL.UI.RayfieldInit = safeImport("UI/RayfieldInit.lua")
ASTRAL.UI.Tabs         = safeImport("UI/Tabs.lua")
ASTRAL.UI.Dropdowns    = safeImport("UI/Dropdowns.lua")
ASTRAL.UI.Settings     = safeImport("UI/Settings.lua")

-- Inject Core into UI that needs Utils, etc.
if ASTRAL.UI.Dropdowns and ASTRAL.UI.Dropdowns.SetDependencies then
    ASTRAL.UI.Dropdowns.SetDependencies(ASTRAL.Core)
end

--========================================================--
--                 FEATURE MODULES
--========================================================--

ASTRAL.Modules.PetViewer   = safeImport("Modules/PetViewer.lua")
ASTRAL.Modules.TeleportHub = safeImport("Modules/TeleportHub.lua")
ASTRAL.Modules.AutoNeeds   = safeImport("Modules/AutoNeeds.lua")
ASTRAL.Modules.AutoPotions = safeImport("Modules/AutoPotions.lua")
ASTRAL.Modules.AutoEggs    = safeImport("Modules/AutoEggs.lua")
ASTRAL.Modules.BabyFarm    = safeImport("Modules/BabyFarm.lua")
ASTRAL.Modules.Webhooks    = safeImport("Modules/Webhooks.lua")

--========================================================--
--                 ASTRAL INITIALIZATION
--========================================================--

local Window
local Tabs

if ASTRAL.UI.RayfieldInit and ASTRAL.UI.RayfieldInit.Init then
    local ok, result = pcall(ASTRAL.UI.RayfieldInit.Init)
    if ok then
        Window = result
    else
        warn("[ASTRAL SafeMode] Failed to initialize Rayfield:", result)
    end
end

if ASTRAL.UI.Tabs and ASTRAL.UI.Tabs.Create then
    local ok, result = pcall(ASTRAL.UI.Tabs.Create, Window)
    if ok then
        Tabs = result
    else
        warn("[ASTRAL SafeMode] Failed to create Tabs:", result)
    end
end

-- Only feature modules need Init()
for name, module in pairs(ASTRAL.Modules) do
    if type(module) == "table" and module.Init then
        task.spawn(function()
            local ok, err = pcall(module.Init, Tabs, ASTRAL.Core, ASTRAL.UI)
            if not ok then
                warn("[ASTRAL SafeMode] Init failed for module:", name, err)
            else
                print("[ASTRAL] Module initialized:", name)
            end
        end)
    else
        if module == nil then
            warn("[ASTRAL SafeMode] Skipping missing module:", name)
        end
    end
end

print("ASTRAL Framework Loaded Successfully (SafeMode Edition)")

return ASTRAL
