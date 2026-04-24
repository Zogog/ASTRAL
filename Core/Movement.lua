--========================================================--
--                 ASTRAL.Core.Movement
--      Centralized movement engine + speed overrides
--========================================================--

local Movement = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Humanoid = nil

--========================================================--
--                 INTERNAL STATE
--========================================================--

-- Movement modes
local mode = "Idle" -- Idle / Platform / Circle
local amplitude = 0.5
local height = 0.1
local speed = 1

-- WalkSpeed / JumpPower overrides
Movement.CurrentWalkSpeed = 16
Movement.CurrentJumpPower = 50

--========================================================--
--                 HELPERS
--========================================================--

local function GetRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
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
--                 SPEED OVERRIDES
--========================================================--

local function ApplyMovementStats()
    if not Humanoid then
        Humanoid = GetHumanoid()
    end

    Humanoid.WalkSpeed = Movement.CurrentWalkSpeed
    Humanoid.JumpPower = Movement.CurrentJumpPower
end

function Movement.SetWalkSpeed(value)
    Movement.CurrentWalkSpeed = value
    ApplyMovementStats()
end

function Movement.SetJumpPower(value)
    Movement.CurrentJumpPower = value
    ApplyMovementStats()
end

--========================================================--
--     ENFORCE SPEED EVERY FRAME (Adopt Me patch)
--========================================================--

RunService.Heartbeat:Connect(function()
    if not Humanoid or Humanoid.Parent == nil then
        Humanoid = GetHumanoid()
    end

    Humanoid.WalkSpeed = Movement.CurrentWalkSpeed
    Humanoid.JumpPower = Movement.CurrentJumpPower
end)

--========================================================--
--                 HANDLE RESPAWNS
--========================================================--

LocalPlayer.CharacterAdded:Connect(function()
    Humanoid = GetHumanoid()
    task.wait(0.1)
    ApplyMovementStats()
end)

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
