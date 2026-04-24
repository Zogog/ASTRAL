--========================================================--
--                 ASTRAL.Modules.AutoEggs
--      Advanced v2 — Auto Hatch, Auto Switch, Teleports
--========================================================--

local Settings = require(script.Parent.Parent.UI.Settings)
local Utils = require(script.Parent.Parent.Core.Utils)

local AutoEggs = {}

--========================================================--
--                 INTERNAL STATE
--========================================================--

local running = false
local selectedEgg = nil
local disabledEggTypes = {}
local MovementMode = "Idle" -- Idle / Platform / Circle

--========================================================--
--                 LOGGING
--========================================================--

local function Log(msg)
    print("[ASTRAL AutoEggs] " .. msg)
end

local function WaitTick()
    task.wait(Settings.GetTickDelay())
end

--========================================================--
--                 MOVEMENT SYSTEM
--========================================================--

local function DoMovement(mode)
    if mode == "Idle" then return end

    local char = game.Players.LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if mode == "Platform" then
        root.CFrame = root.CFrame + Vector3.new(0, 0.1, 0)

    elseif mode == "Circle" then
        local t = tick()
        root.CFrame = root.CFrame * CFrame.new(math.sin(t) * 0.5, 0, math.cos(t) * 0.5)
    end
end

--========================================================--
--                 EGG SWITCHING
--========================================================--

local function SwitchIfHatched(API, eggUnique)
    if not eggUnique then return nil end

    if API.IsEggNotThere(eggUnique) then
        Log("Egg hatched — switching to next egg")

        local nextEgg = API.GetRandomKind(eggUnique)
        if nextEgg then
            Log("Next egg: " .. nextEgg)
            return nextEgg
        end

        Log("No more eggs available")
        return nil
    end

    return eggUnique
end

local function IsEggDisabled(API, eggUnique)
    local cfg = API.GetPlayersPetConfigs(eggUnique)
    local kind = cfg.petKind:lower()

    for _, disabled in ipairs(disabledEggTypes) do
        if kind:find(disabled) then
            return true
        end
    end

    return false
end

--========================================================--
--                 TELEPORT LOGIC
--========================================================--

local function TeleportForEgg(API, eggUnique)
    local cfg = API.GetPlayersPetConfigs(eggUnique)
    local kind = cfg.petKind:lower()

    -- Basic routing for egg types
    if kind:find("cracked") then
        API.GoToStore("Nursery")
        return
    end

    if kind:find("royal") then
        API.GoToStore("Nursery")
        return
    end

    if kind:find("pet") then
        API.GoToStore("Nursery")
        return
    end

    -- Default fallback
    API.GoToStore("Nursery")
end

--========================================================--
--                 MAIN LOOP
--========================================================--

local function StartLoop(API)
    running = true
    Log("AutoEggs Advanced v2 started")

    while running do
        task.wait()

        DoMovement(MovementMode)

        if not selectedEgg then
            Log("No egg selected")
            task.wait(1)
            continue
        end

        -- Skip disabled egg types
        if IsEggDisabled(API, selectedEgg) then
            Log("Egg type disabled — skipping")
            task.wait(2)
            continue
        end

        -- Auto-switch hatched eggs
        selectedEgg = SwitchIfHatched(API, selectedEgg)
        if not selectedEgg then
            Log("No eggs left — stopping")
            running = false
            break
        end

        -- Ensure egg equipped
        local equipped = API.GetPlayersEquippedPets()
        local found = false

        for _, v in pairs(equipped) do
            if v.unique == selectedEgg then
                found = true
                break
            end
        end

        if not found then
            Log("Equipping egg: " .. selectedEgg)
            API.EquipPet(selectedEgg)
            WaitTick()
        end

        -- Teleport to correct hatching area
        TeleportForEgg(API, selectedEgg)
        WaitTick()
    end

    Log("AutoEggs stopped")
end

--========================================================--
--                 UI CREATION
--========================================================--

function AutoEggs.Init(Tabs, API)
    local tab = Tabs.Autofarm

    tab:CreateSection("Auto Eggs — Advanced v2")

    -- Enable toggle
    tab:CreateToggle({
        Name = "Enable Auto Eggs",
        CurrentValue = false,
        Callback = function(state)
            if state then
                task.spawn(StartLoop, API)
            else
                running = false
            end
        end,
    })

    -- Egg selection
    tab:CreateInput({
        Name = "Egg Unique ID",
        PlaceholderText = "Enter egg unique ID",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            selectedEgg = text ~= "" and text or nil
            if selectedEgg then
                Log("Selected egg: " .. selectedEgg)
            end
        end,
    })

    -- Disabled egg types
    tab:CreateInput({
        Name = "Disabled Egg Types (comma separated)",
        PlaceholderText = "cracked,royal,pet",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            disabledEggTypes = {}
            for egg in string.gmatch(text, "([^,]+)") do
                table.insert(disabledEggTypes, Utils.Normalize(egg))
            end
            Log("Disabled egg types updated")
        end,
    })

    -- Movement mode
    tab:CreateDropdown({
        Name = "Movement Mode",
        Options = {"Idle", "Platform", "Circle"},
        CurrentOption = "Idle",
        Callback = function(opt)
            MovementMode = opt
        end,
    })

    -- Stop button
    tab:CreateButton({
        Name = "Force Stop Auto Eggs",
        Callback = function()
            running = false
        end,
    })
end

return AutoEggs
