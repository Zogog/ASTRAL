--========================================================--
--                 ASTRAL.Modules.BabyFarm
--      Advanced v2 — Baby Ailments, Teleports, Movement
--========================================================--

local Settings = require(script.Parent.Parent.UI.Settings)
local Utils = require(script.Parent.Parent.Core.Utils)

local BabyFarm = {}

--========================================================--
--                 INTERNAL STATE
--========================================================--

local running = false
local MovementMode = "Idle" -- Idle / Platform / Circle
local DisabledAilments = {}

--========================================================--
--                 LOGGING
--========================================================--

local function Log(msg)
    print("[ASTRAL BabyFarm] " .. msg)
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
--                 BABY AILMENT SOLVING
--========================================================--

local function SolveAilment(API, ailment)
    ailment = ailment:lower()

    if ailment == "hungry" or ailment == "thirsty" then
        Log("Baby needs food/water — going home")
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "sleepy" then
        Log("Baby needs sleep — going home")
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "dirty" then
        Log("Baby needs shower — going home")
        API.GoToHome()
        WaitTick()
        return
    end

    if ailment == "school" then
        Log("Baby needs school — going to School")
        API.GoToStore("School")
        WaitTick()
        return
    end

    if ailment == "hospital" then
        Log("Baby needs healing — going to Hospital")
        API.GoToStore("Hospital")
        WaitTick()
        return
    end

    if ailment == "salon" then
        Log("Baby needs Salon — going to Salon")
        API.GoToStore("Salon")
        WaitTick()
        return
    end

    Log("Unknown baby ailment: " .. ailment)
end

local function SolveAll(API, ailments)
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
    Log("BabyFarm Advanced v2 started")

    -- Ensure player is Baby
    API.SetPlayerToBaby()
    WaitTick()

    while running do
        task.wait()

        DoMovement(MovementMode)

        -- Get baby ailments
        local ailments = API.GetAilments(
            nil, -- Pet1
            nil, -- Pet2
            "BABY",
            DisabledAilments
        )

        if Utils.IsEmpty(ailments.Baby) then
            task.wait(1)
            continue
        end

        SolveAll(API, ailments)
    end

    Log("BabyFarm stopped")
end

--========================================================--
--                 UI CREATION
--========================================================--

function BabyFarm.Init(Tabs, API)
    local tab = Tabs.Autofarm

    tab:CreateSection("Baby Farm — Advanced v2")

    -- Enable toggle
    tab:CreateToggle({
        Name = "Enable Baby Farm",
        CurrentValue = false,
        Callback = function(state)
            if state then
                task.spawn(StartLoop, API)
            else
                running = false
            end
        end,
    })

    -- Disabled ailments
    tab:CreateInput({
        Name = "Disabled Baby Ailments (comma separated)",
        PlaceholderText = "school,hospital,salon",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            DisabledAilments = {}
            for ail in string.gmatch(text, "([^,]+)") do
                table.insert(DisabledAilments, Utils.Normalize(ail))
            end
            Log("Disabled baby ailments updated")
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
        Name = "Force Stop Baby Farm",
        Callback = function()
            running = false
        end,
    })
end

return BabyFarm
