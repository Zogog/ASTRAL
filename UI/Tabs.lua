--========================================================--
--                     ASTRAL.UI.Tabs
--        Creates and returns all Rayfield tabs
--========================================================--

local Tabs = {}

function Tabs.Create(Window)
    -- All icons use Lucide icon names (Rayfield standard)
    local TabList = {
        Main      = Window:CreateTab("Main", "home"),
        Pets      = Window:CreateTab("Pets", "paw-print"),
        Teleports = Window:CreateTab("Teleports", "map"),
        Autofarm  = Window:CreateTab("Autofarm", "sparkles"),
        Misc      = Window:CreateTab("Misc", "settings"),
    }

    return TabList
end

return Tabs
