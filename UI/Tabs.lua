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
        Extras    = Window:CreateTab("Extras", "settings"),

    }

    return TabList
end

return Tabs
