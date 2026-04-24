--========================================================--
--                 ASTRAL.Modules.AutoNeeds
--      Advanced v2 — Dual Pets, Eggs, Baby, Movement
--========================================================--

local AutoNeeds = {}

local Settings
local Utils

--========================================================--
--                 INTERNAL STATE
--========================================================--

local running = false

local Selected = {
    Pet1 = nil,
    Pet2 = nil,
    Baby = false,
}

local DisabledAilments = {}
local MovementMode = "Idle" -- Idle / Platform / Circle

--========================================================--
--                 LOGGING
--========================================================--

local function Log(msg)
    print("[ASTRAL AutoNeeds] " .. msg)
end

local function WaitTick()
    task.wait(Settings.GetTickDelay())
end

--========================================================--
--                 MOVEMENT SYSTEM
--========================================================--

local function DoMovement(mode)
    if mode == "Idle" then
        return
    end

    local root = game.Players.LocalPlayer.Character
        and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if mode == "Platform" then
        root.CFrame = root.CFrame + Vector3.new(0, 0.1, 0)
    elseif mode == "Circle" then
        local t = tick()
        root.CFrame = root.CFrame * CFrame.new(math.sin(t) * 0.5, 0, math.cos(t) * 0.5)
    end
end

--========================================================--
--                 PET SWITCHING
--========================================================--

local function SwitchIfFullGrown(API, petUnique)
    local cfg = API.GetPlayersPetConfigs(petUnique)
    if cfg.petAge < 6 then return petUnique end

    Log("Pet full grown — switching")

    local nextPet = API.GetSameKind(Selected.Pet1, Selected.Pet2, cfg.petKind)
    if nextPet then
        Log("Switching to same kind: " .. nextPet)
        return nextPet
    end

    local randomPet = API.GetRandomKind(petUnique)
    if randomPet then
        Log("Switching to random pet of same type")
        return randomPet
    end

    Log("No replacement pet found")
    return petUnique
end

local function SwitchIfEggHatched(API, petUnique)
    if not API.GetPetConfigs(API.GetPlayersPetConfigs(petUnique).petKind).isEgg then
        return petUnique
    end

    if API.IsEggNotThere and API.IsEggNotThere(petUnique) then
        Log("Egg hatched — switching")
        return API.GetRandomKind(petUnique)
    end

    return petUnique
end

--========================================================--
--                 AILMENT SOLVING
--========================================================--

local function SolveAilment(API, ailment)
    ailment = ailment:lower()

    if ailment == "hungry" or ailment == "thirsty" then
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "sleepy" then
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "dirty" then
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "school" then
        API.GoToStore("School")
        WaitTick()
        return
    end

    if ailment == "hospital" then
        API.GoToStore("Hospital")
        WaitTick()
        return
    end

    if ailment == "salon" then
        API.GoToStore("Salon")
        WaitTick()
        return
    end

    Log("Unknown ailment: " .. ailment)
end

local function SolveAll(API, ailments)
    for ailment in pairs(ailments.FirstPet) do
        SolveAilment(API, ailment)
        WaitTick()
    end

    for ailment in pairs(ailments.SecondPet) do
        SolveAilment(API, ailment)
        WaitTick()
    end

    for ailment in pairs(ailments.Baby) do
        SolveAilment(API, ailment)
        WaitTick()
    end
end

--========================================================--
--                 MAIN LOOP
--========================================================--

local function StartLoop(API)
    running = true
    Log("AutoNeeds Advanced v2 started")

    while running do
        task.wait()

        DoMovement(MovementMode)

        if not Selected.Pet1 then
            Log("No Pet 1 selected")
            task.wait(1)
            continue
        end

        Selected.Pet1 = SwitchIfFullGrown(API, Selected.Pet1)
        Selected.Pet2 = Selected.Pet2 and SwitchIfFullGrown(API, Selected.Pet2)

        Selected.Pet1 = SwitchIfEggHatched(API, Selected.Pet1)
        Selected.Pet2 = Selected.Pet2 and SwitchIfEggHatched(API, Selected.Pet2)

        local equipped = API.GetPlayersEquippedPets()
        local has1, has2 = false, false

        for _, v in pairs(equipped) do
            if v.unique == Selected.Pet1 then has1 = true end
            if v.unique == Selected.Pet2 then has2 = true end
        end

        if not has1 then
            API.EquipPet(Selected.Pet1)
            WaitTick()
        end

        if Selected.Pet2 and not has2 then
            API.EquipPet(Selected.Pet2)
            WaitTick()
        end

        local ailments = API.GetAilments(
            Selected.Pet1,
            Selected.Pet2,
            Selected.Baby and "BABY" or nil,
            DisabledAilments
        )

        if Utils.IsEmpty(ailments.FirstPet)
        and Utils.IsEmpty(ailments.SecondPet)
        and Utils.IsEmpty(ailments.Baby) then
            task.wait(1)
            continue
        end

        SolveAll(API, ailments)
    end

    Log("AutoNeeds stopped")
end

--========================================================--
--                 UI CREATION
--========================================================--

function AutoNeeds.Init(Tabs, Core, UI)
    Settings = UI.Settings
    Utils    = Core.Utils

    local API = Core.AdoptMeAPI
    local tab = Tabs.Autofarm

    tab:CreateSection("Auto Needs — Advanced v2")

    tab:CreateToggle({
        Name = "Enable Auto Needs",
        CurrentValue = false,
        Callback = function(state)
            if state then
                task.spawn(StartLoop, API)
            else
                running = false
            end
        end,
    })

    tab:CreateInput({
        Name = "Pet 1 Unique ID",
        PlaceholderText = "Enter pet unique ID",
        Callback = function(text)
            Selected.Pet1 = text ~= "" and text or nil
        end,
    })

    tab:CreateInput({
        Name = "Pet 2 Unique ID (optional)",
        PlaceholderText = "Enter pet unique ID",
        Callback = function(text)
            Selected.Pet2 = text ~= "" and text or nil
        end,
    })

    tab:CreateToggle({
        Name = "Include Baby Needs",
        CurrentValue = false,
        Callback = function(state)
            Selected.Baby = state
        end,
    })

    tab:CreateInput({
        Name = "Disabled Ailments (comma separated)",
        PlaceholderText = "school,hospital,salon",
        Callback = function(text)
            DisabledAilments = {}
            for ail in string.gmatch(text, "([^,]+)") do
                table.insert(DisabledAilments, Utils.Normalize(ail))
            end
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
        Name = "Force Stop Auto Needs",
        Callback = function()
            running = false
        end,
    })
end

return AutoNeeds
