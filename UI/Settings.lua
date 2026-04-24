--========================================================--
--                 ASTRAL.UI.Settings
--     Performance, rendering, and general UI settings
--========================================================--

local Settings = {
    Values = {
        TickDelay = 2,
        FPSCap = 60,
        RenderingEnabled = true,
        AntiAFK = true,
    }
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

--========================================================--
--                 INTERNAL: ANTI-AFK HANDLER
--========================================================--

local function EnableAntiAFK()
    if Settings._AntiAFKConnection then
        Settings._AntiAFKConnection:Disconnect()
        Settings._AntiAFKConnection = nil
    end

    Settings._AntiAFKConnection = Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local function DisableAntiAFK()
    if Settings._AntiAFKConnection then
        Settings._AntiAFKConnection:Disconnect()
        Settings._AntiAFKConnection = nil
    end
end

--========================================================--
--                 INITIALIZATION
--========================================================--

function Settings.Init(Tabs)
    local tab = Tabs.Misc

    tab:CreateSection("Performance Settings")

    -- Rendering Toggle
    tab:CreateToggle({
        Name = "Disable Rendering (White Screen)",
        CurrentValue = not Settings.Values.RenderingEnabled,
        Callback = function(state)
            Settings.Values.RenderingEnabled = not state
            RunService:Set3dRenderingEnabled(Settings.Values.RenderingEnabled)
        end,
    })

    -- FPS Cap Slider
    tab:CreateSlider({
        Name = "FPS Cap",
        Range = {5, 240},
        Increment = 1,
        Suffix = "FPS",
        CurrentValue = Settings.Values.FPSCap,
        Callback = function(value)
            Settings.Values.FPSCap = value

            local ok = pcall(function()
                setfpscap(value)
            end)

            if not ok then
                warn("Executor does not support setfpscap")
            end
        end,
    })

    -- Tick Delay Slider
    tab:CreateSlider({
        Name = "Tick Delay",
        Range = {0.1, 5},
        Increment = 0.1,
        Suffix = "Seconds",
        CurrentValue = Settings.Values.TickDelay,
        Callback = function(value)
            Settings.Values.TickDelay = value
        end,
    })

    tab:CreateSection("AFK Settings")

    -- Anti-AFK Toggle
    tab:CreateToggle({
        Name = "Enable Anti-AFK",
        CurrentValue = Settings.Values.AntiAFK,
        Callback = function(state)
            Settings.Values.AntiAFK = state
            if state then
                EnableAntiAFK()
            else
                DisableAntiAFK()
            end
        end,
    })

    -- Enable Anti-AFK on startup
    if Settings.Values.AntiAFK then
        EnableAntiAFK()
    end
end

--========================================================--
--                 GETTERS FOR OTHER MODULES
--========================================================--

function Settings.GetTickDelay()
    return Settings.Values.TickDelay
end

function Settings.GetFPSCap()
    return Settings.Values.FPSCap
end

function Settings.IsRenderingEnabled()
    return Settings.Values.RenderingEnabled
end

function Settings.IsAntiAFKEnabled()
    return Settings.Values.AntiAFK
end

--========================================================--
--                 EXPORT
--========================================================--

return Settings
