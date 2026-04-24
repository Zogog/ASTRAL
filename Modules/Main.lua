--========================================================--
--                 ASTRAL.Modules.Main
--========================================================--

local Main = {}

local StartTime = os.time()

local function Log(msg)
    print("[ASTRAL Main] " .. msg)
end

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function SafeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then
        warn("[ASTRAL Main] Error:", result)
        return nil
    end
    return result
end

local function GetMoney(API)
    local data = SafeCall(API.GetClientData)
    if not data or not data.Bucks then return "?" end
    return tostring(data.Bucks)
end

local function GetInterior(API)
    local interior = SafeCall(API.GetCurrentInterior)
    return interior or "Unknown"
end

local function GetEquippedPetsString(API)
    local pets = SafeCall(API.GetEquippedPets)
    if not pets or #pets == 0 then
        return "None"
    end

    local parts = {}
    for _, pet in ipairs(pets) do
        local name = pet.Name or "Pet"
        local age = pet.Age or "?"
        table.insert(parts, string.format("%s (age %s)", name, age))
    end

    return table.concat(parts, ", ")
end

local function GetModuleStatus(Modules, key)
    local mod = Modules[key]
    if not mod or not mod.GetStatus then
        return "unknown"
    end
    local status = SafeCall(mod.GetStatus)
    return status or "unknown"
end

function Main.Init(Tabs, Core, UI)
    if not Tabs then
        warn("[ASTRAL Main] Tabs not available, skipping Main dashboard")
        return
    end

    local API = Core.AdoptMeAPI or {}
    local Modules = Core.Modules or {}

    local tab = Tabs.Main or Tabs:CreateTab("Main", "home")

    --========================================================--
    --                 ASTRAL STATUS
    --========================================================--

    tab:CreateSection("ASTRAL Status")

    local VersionLabel = tab:CreateLabel("Version: v2.0")
    local SafeModeLabel = tab:CreateLabel("SafeMode: ON")
    local ModulesLabel = tab:CreateLabel("Modules: loading...")
    local GitHubLabel  = tab:CreateLabel("GitHub: OK")

    --========================================================--
    --                 PLAYER INFO
    --========================================================--

    tab:CreateSection("Player Info")

    local Player = game.Players.LocalPlayer
    local PlayerName = Player and Player.Name or "Unknown"

    local PlayerLabel  = tab:CreateLabel("Player: " .. PlayerName)
    local MoneyLabel   = tab:CreateLabel("Money: ?")
    local InteriorLabel = tab:CreateLabel("Interior: Unknown")

    --========================================================--
    --                 EQUIPPED PETS
    --========================================================--

    tab:CreateSection("Equipped Pets")

    local EquippedPetsLabel = tab:CreateLabel("Equipped: loading...")
    local BabyFarmLabel     = tab:CreateLabel("Baby Farm: unknown")

    --========================================================--
    --                 SESSION STATS
    --========================================================--

    tab:CreateSection("Session Stats")

    local RuntimeLabel = tab:CreateLabel("Runtime: 00:00:00")
    local BucksLabel   = tab:CreateLabel("Bucks: 0 (+0)")
    local PotionsLabel = tab:CreateLabel("Potions: 0 (+0)")
    local EggsLabel    = tab:CreateLabel("Candy Eggs: 0 (+0)")

    local StartBucks = tonumber(GetMoney(API)) or 0
    local LastBucks  = StartBucks
    local PotionsGained = 0
    local EggsGained    = 0

    --========================================================--
    --                 FARM STATUS
    --========================================================--

    tab:CreateSection("Farm Status")

    local AutoNeedsStatusLabel   = tab:CreateLabel("AutoNeeds: unknown")
    local BabyFarmStatusLabel    = tab:CreateLabel("BabyFarm: unknown")
    local AutoEggsStatusLabel    = tab:CreateLabel("AutoEggs: unknown")
    local AutoPotionsStatusLabel = tab:CreateLabel("AutoPotions: unknown")

    --========================================================--
    --                 AUTO REFRESH LOOP
    --========================================================--

    Log("Main dashboard initialized")

    task.spawn(function()
        while true do
            task.wait(1)

            -- Runtime
            local runtime = os.time() - StartTime
            RuntimeLabel:Set("Runtime: " .. FormatTime(runtime))

            -- Money + Bucks gained
            local moneyStr = GetMoney(API)
            MoneyLabel:Set("Money: " .. moneyStr)

            local currentBucks = tonumber(moneyStr) or LastBucks
            local diff = currentBucks - StartBucks
            BucksLabel:Set(string.format("Bucks: %d (+%d)", currentBucks, diff))
            LastBucks = currentBucks

            -- Interior
            InteriorLabel:Set("Interior: " .. GetInterior(API))

            -- Equipped pets
            EquippedPetsLabel:Set("Equipped: " .. GetEquippedPetsString(API))

            -- BabyFarm status
            BabyFarmLabel:Set("Baby Farm: " .. GetModuleStatus(Core.Modules or {}, "BabyFarm"))

            -- Farm status
            AutoNeedsStatusLabel:Set("AutoNeeds: " .. GetModuleStatus(Core.Modules or {}, "AutoNeeds"))
            BabyFarmStatusLabel:Set("BabyFarm: " .. GetModuleStatus(Core.Modules or {}, "BabyFarm"))
            AutoEggsStatusLabel:Set("AutoEggs: " .. GetModuleStatus(Core.Modules or {}, "AutoEggs"))
            AutoPotionsStatusLabel:Set("AutoPotions: " .. GetModuleStatus(Core.Modules or {}, "AutoPotions"))

            -- ASTRAL status
            local safeMode = Core.SafeMode
            SafeModeLabel:Set("SafeMode: " .. (safeMode and "ON" or "OFF"))

            -- Placeholder until you wire module tracking
            ModulesLabel:Set("Modules: dynamic tracking coming soon")
        end
    end)
end

return Main
