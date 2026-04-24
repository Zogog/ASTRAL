--========================================================--
--                 ASTRAL.Modules.AutoEggs
--========================================================--

local AutoEggs = {}

local running = false
local selectedEgg = nil
local disabledEggTypes = {}
local MovementMode = "Idle"

local function Log(msg)
    print("[ASTRAL AutoEggs] " .. msg)
end

local function WaitTick(Settings)
    task.wait(Settings.GetTickDelay())
end

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

local function IsEggDisabled(API, eggUnique, Utils)
    local cfg = API.GetPlayersPetConfigs(eggUnique)
    local kind = cfg.petKind:lower()

    for _, disabled in ipairs(disabledEggTypes) do
        if kind:find(disabled) then
            return true
        end
    end

    return false
end

local function TeleportForEgg(API, eggUnique)
    local cfg = API.GetPlayersPetConfigs(eggUnique)
    local kind = cfg.petKind:lower()

    API.GoToStore("Nursery")
end

local function StartLoop(API, Core, UI)
    local Settings = UI.Settings
    local Utils = Core.Utils

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

        if IsEggDisabled(API, selectedEgg, Utils) then
            Log("Egg type disabled — skipping")
            task.wait(2)
            continue
        end

        selectedEgg = SwitchIfHatched(API, selectedEgg)
        if not selectedEgg then
            Log("No eggs left — stopping")
            running = false
            break
        end

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
            WaitTick(Settings)
        end

        TeleportForEgg(API, selectedEgg)
        WaitTick(Settings)
    end

    Log("AutoEggs stopped")
end

function AutoEggs.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local Utils = Core.Utils
    local Settings = UI.Settings

    local tab = Tabs.Autofarm

    tab:CreateSection("Auto Eggs — Advanced v2")

    tab:CreateToggle({
        Name = "Enable Auto Eggs",
        CurrentValue = false,
        Callback = function(state)
            if state then
                task.spawn(StartLoop, API, Core, UI)
            else
                running = false
            end
        end,
    })

    tab:CreateInput({
        Name = "Egg Unique ID",
        PlaceholderText = "Enter egg unique ID",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            selectedEgg = text ~= "" and text or nil
            if selectedEgg then Log("Selected egg: " .. selectedEgg) end
        end,
    })

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

    tab:CreateDropdown({
        Name = "Movement Mode",
        Options = {"Idle", "Platform", "Circle"},
        CurrentOption = "Idle",
        Callback = function(opt)
            MovementMode = opt
        end,
    })

    tab:CreateButton({
        Name = "Force Stop Auto Eggs",
        Callback = function()
            running = false
        end,
    })
end

return AutoEggs
