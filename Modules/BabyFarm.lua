--========================================================--
--                 ASTRAL.Modules.BabyFarm
--========================================================--

local BabyFarm = {}

local running = false
local MovementMode = "Idle"
local DisabledAilments = {}

local function Log(msg)
    print("[ASTRAL BabyFarm] " .. msg)
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

local function SolveAilment(API, ailment)
    ailment = ailment:lower()

    if ailment == "hungry" or ailment == "thirsty" or ailment == "sleepy" or ailment == "dirty" then
        API.GoToHome()
        return
    end

    if ailment == "school" then API.GoToStore("School") return end
    if ailment == "hospital" then API.GoToStore("Hospital") return end
    if ailment == "salon" then API.GoToStore("Salon") return end
end

local function SolveAll(API, ailments)
    for ailment in pairs(ailments.Baby) do
        SolveAilment(API, ailment)
    end
end

local function StartLoop(API, Core, UI)
    local Settings = UI.Settings
    local Utils = Core.Utils

    running = true
    Log("BabyFarm Advanced v2 started")

    API.SetPlayerToBaby()
    WaitTick(Settings)

    while running do
        task.wait()

        DoMovement(MovementMode)

        local ailments = API.GetAilments(nil, nil, "BABY", DisabledAilments)

        if Utils.IsEmpty(ailments.Baby) then
            task.wait(1)
            continue
        end

        SolveAll(API, ailments)
        WaitTick(Settings)
    end

    Log("BabyFarm stopped")
end

function BabyFarm.Init(Tabs,
