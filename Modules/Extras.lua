--========================================================--
--                 ASTRAL.Modules.Extras
--     Player Settings / Performance / QoL Controls
--========================================================--

local Extras = {}

function Extras.Init(Tabs, Core, UI)
    local tab = Tabs.Extras
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")

    tab:CreateSection("Player Movement")

    --------------------------------------------------------
    -- WalkSpeed (patched to use Core.Movement)
    --------------------------------------------------------
    tab:CreateSlider({
        Name = "WalkSpeed",
        Range = { 0, 100 },
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,

        Callback = function(value)
            if Core.Movement and Core.Movement.SetWalkSpeed then
                Core.Movement.SetWalkSpeed(value)
            else
                warn("[ASTRAL] Movement.SetWalkSpeed missing")
            end
        end,
    })

    --------------------------------------------------------
    -- JumpPower (patched to use Core.Movement)
    --------------------------------------------------------
    tab:CreateSlider({
        Name = "JumpPower",
        Range = { 0, 250 },
        Increment = 1,
        Suffix = "Power",
        CurrentValue = 50,

        Callback = function(value)
            if Core.Movement and Core.Movement.SetJumpPower then
                Core.Movement.SetJumpPower(value)
            else
                warn("[ASTRAL] Movement.SetJumpPower missing")
            end
        end,
    })

    --------------------------------------------------------
    -- Performance Section
    --------------------------------------------------------
    tab:CreateSection("Performance")

    --------------------------------------------------------
    -- Disable Rendering
    --------------------------------------------------------
    tab:CreateToggle({
        Name = "Disable Rendering (white screen, boosts FPS)",
        CurrentValue = false,

        Callback = function(state)
            RunService:Set3dRenderingEnabled(not state)
        end,
    })

    --------------------------------------------------------
    -- FPS Cap
    --------------------------------------------------------
    tab:CreateSlider({
        Name = "FPS Cap",
        Range = { 5, 240 },
        Increment = 1,
        Suffix = "FPS",
        CurrentValue = 60,

        Callback = function(value)
            local ok = pcall(function()
                setfpscap(value)
            end)

            if not ok then
                tab:CreateLabel("Your executor does not support fpscap.", "alert-triangle")
            end
        end,
    })

    --------------------------------------------------------
    -- Tick Delay (for future autofarms)
    --------------------------------------------------------
    Extras.TickDelay = 2

    tab:CreateSlider({
        Name = "Tick Delay",
        Range = { 0.1, 5 },
        Increment = 0.1,
        Suffix = "Seconds",
        CurrentValue = 2,

        Callback = function(value)
            Extras.TickDelay = value
        end,
    })

    --------------------------------------------------------
    -- Anti-AFK
    --------------------------------------------------------
    tab:CreateSection("Quality of Life")

    tab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = true,

        Callback = function(state)
            if state then
                Extras.AntiAFKConnection = Core.LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            else
                if Extras.AntiAFKConnection then
                    Extras.AntiAFKConnection:Disconnect()
                    Extras.AntiAFKConnection = nil
                end
            end
        end,
    })
end

return Extras
