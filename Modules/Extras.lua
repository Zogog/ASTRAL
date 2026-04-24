--========================================================--
--                 ASTRAL.Modules.Extras
--     Player Settings / Performance / QoL Controls
--========================================================--

local Extras = {}

function Extras.Init(Tabs, Core, UI)
    local tab = Tabs.Extras
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    tab:CreateSection("Player Movement")

    --------------------------------------------------------
    -- WalkSpeed (TBIGUI-style)
    --------------------------------------------------------
    tab:CreateSlider({
        Name = "WalkSpeed",
        Range = { 0, 100 },
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,

        Callback = function(value)
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")

            hum.WalkSpeed = value
        end,
    })

    --------------------------------------------------------
    -- JumpPower (TBIGUI-style)
    --------------------------------------------------------
    tab:CreateSlider({
        Name = "JumpPower",
        Range = { 0, 250 },
        Increment = 1,
        Suffix = "Power",
        CurrentValue = 50,

        Callback = function(value)
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")

            hum.JumpPower = value
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
                Extras.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
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
