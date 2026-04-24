--========================================================--
--                 ASTRAL.Modules.AutoNeeds
--      Clean, modular auto-needs system (Hybrid v1)
--========================================================--

local Settings = require(script.Parent.Parent.UI.Settings)
local Utils = require(script.Parent.Parent.Core.Utils)

local AutoNeeds = {}

--========================================================--
--                 INTERNAL STATE
--========================================================--

local running = false
local disabledAilments = {}
local selectedPet = nil
local selectedBaby = false

--========================================================--
--                 INTERNAL HELPERS
--========================================================--

local function Log(msg)
    print("[ASTRAL AutoNeeds] " .. msg)
end

local function WaitTick()
    task.wait(Settings.GetTickDelay())
end

local function GetAilments(API)
    if not selectedPet then return {} end

    return API.GetAilments(
        selectedPet,
        nil, -- second pet (future expansion)
        selectedBaby and "BABY" or nil,
        disabledAilments
    )
end

local function SolveAilment(API, ailment)
    -- Basic routing logic
    if ailment == "hungry" or ailment == "thirsty" then
        Log("Going home for food/water")
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "sleepy" then
        Log("Going home for sleep")
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "dirty" then
        Log("Going home for shower")
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "school" then
        Log("Going to School")
        API.GoToStore("School")
        WaitTick()
        return
    end

    if ailment == "hospital" then
        Log("Going to Hospital")
        API.GoToStore("Hospital")
        WaitTick()
        return
    end

    if ailment == "salon" then
        Log("Going to Salon")
        API.GoToStore("Salon")
        WaitTick()
        return
    end

    -- Unknown ailment (future expansion)
    Log("Unknown ailment: " .. tostring(ailment))
end

local function SolveAllAilments(API, ailmentTable)
    -- First pet
    for ailment, _ in pairs(ailmentTable.FirstPet) do
        SolveAilment(API, ailment)
        WaitTick()
    end

    -- Baby
    for ailment, _ in pairs(ailmentTable.Baby) do
        SolveAilment(API, ailment)
        WaitTick()
    end
end

--========================================================--
--                 MAIN LOOP
--========================================================--

local function StartLoop(API)
    running = true
    Log("AutoNeeds started")

    while running do
        task.wait()

        if not selectedPet then
            Log("No pet selected")
            task.wait(1)
            continue
        end

        -- Ensure pet is equipped
        local equipped = API.GetPlayersEquippedPets()
        local found = false

        for _, v in pairs(equipped) do
            if v.unique == selectedPet then
                found = true
                break
            end
        end

        if not found then
            Log("Equipping pet: " .. selectedPet)
            API.EquipPet(selectedPet)
            WaitTick()
        end

        -- Get ailments
        local ailments = GetAilments(API)

        if Utils.IsEmpty(ailments.FirstPet) and Utils.IsEmpty(ailments.Baby) then
            -- No needs
            task.wait(1)
            continue
        end

        -- Solve ailments
        SolveAllAilments(API, ailments)
    end

    Log("AutoNeeds stopped")
end

--========================================================--
--                 UI CREATION
--========================================================--

function AutoNeeds.Init(Tabs, API)
    local tab = Tabs.Autofarm

    tab:CreateSection("Auto Needs")

    -- Toggle
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

    -- Pet selection
    tab:CreateInput({
        Name = "Pet Unique ID",
        PlaceholderText = "Enter pet unique ID",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            if text == "" then
                selectedPet = nil
                return
            end
            selectedPet = text
            Log("Selected pet: " .. text)
        end,
    })

    -- Baby toggle
    tab:CreateToggle({
        Name = "Include Baby Needs",
        CurrentValue = false,
        Callback = function(state)
            selectedBaby = state
        end,
    })

    -- Disabled ailments
    tab:CreateInput({
        Name = "Disabled Ailments (comma separated)",
        PlaceholderText = "Example: school,hospital",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            disabledAilments = {}

            for ail in string.gmatch(text, "([^,]+)") do
                table.insert(disabledAilments, Utils.Normalize(ail))
            end

            Log("Disabled ailments updated")
        end,
    })

    -- Stop button
    tab:CreateButton({
        Name = "Force Stop Auto Needs",
        Callback = function()
            running = false
        end,
    })
end

return AutoNeeds
