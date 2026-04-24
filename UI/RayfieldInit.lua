--========================================================--
--                 ASTRAL.UI.RayfieldInit
--        Initializes Rayfield and returns the Window
--========================================================--

local RayfieldInit = {}

function RayfieldInit.Init()
    -- Load Rayfield UI Library
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

    -- Create the main ASTRAL window
    local Window = Rayfield:CreateWindow({
        Name = "ASTRAL Hub",
        LoadingTitle = "ASTRAL",
        LoadingSubtitle = "Initializing...",
        Theme = "Default",

        -- Recommended for custom hubs
        DisableRayfieldPrompts = true,
        DisableBuildWarnings = false,

        ConfigurationSaving = {
            Enabled = true,
            FolderName = "ASTRAL_CONFIGS",
            FileName = "ASTRAL_UI",
        },
    })

    return Window
end

return RayfieldInit
