--========================================================--
--                 ASTRAL.Core.Movement
--      Centralized movement engine for all modules
--========================================================--

local Movement = {}

--========================================================--
--                 INTERNAL STATE
--========================================================--

local mode = "Idle" -- Idle / Platform / Circle
local amplitude = 0.5 -- circle radius
local height = 0.1 -- platform lift
local speed = 1 -- circle speed multiplier

--========================================================--
--                 HELPERS
--========================================================--

local function GetRoot()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

--========================================================--
--                 MOVEMENT MODES
--========================================================--

local function Idle()
    -- Do nothing
end

local function Platform()
    local root = GetRoot()
    if not root then return end

    root.CFrame = root.CFrame + Vector3.new(0, height, 0)
end

local function Circle()
    local root = GetRoot()
    if not root then return end

    local t = tick() * speed
    local x = math.sin(t) * amplitude
    local z = math.cos(t) * amplitude

    root.CFrame = root.CFrame * CFrame.new(x, 0, z)
end

--========================================================--
--                 MAIN EXECUTION
--========================================================--

function Movement.Do()
    if mode == "Idle" then
        Idle()
    elseif mode == "Platform" then
        Platform()
    elseif mode == "Circle" then
        Circle()
    end
end

--========================================================--
--                 CONFIGURATION
--========================================================--

function Movement.SetMode(newMode)
    mode = newMode
end

function Movement.SetAmplitude(value)
    amplitude = value
end

function Movement.SetHeight(value)
    height = value
end

function Movement.SetSpeed(value)
    speed = value
end

function Movement.GetMode()
    return mode
end

--========================================================--
--                 EXPORT
--========================================================--

return Movement
