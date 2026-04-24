--========================================================--
--               ASTRAL.Modules.TeleportHub
--        Clean, modular teleport hub for Adopt Me
--========================================================--

local TeleportHub = {}

--========================================================--
--               TELEPORT DEFINITIONS
--========================================================--

local Teleports = {
    ["Main Areas"] = {
        { Name = "Main Map",      Func = "GoToMainMap" },
        { Name = "Neighborhood",  Func = "GoToNeighborhood" },
        { Name = "Your House",    Func = "GoToHome" },
    },

    ["Shops & Buildings"] = {
        -- These require you to know the interior name
        -- You can expand this list as you discover more
        { Name = "Nursery",       Store = "Nursery" },
        { Name = "School",        Store = "School" },
        { Name = "Hospital",      Store = "Hospital" },
        { Name = "Pizza Shop",    Store = "PizzaShop" },
        { Name = "Salon",         Store = "Salon" },
        { Name = "Baby Shop",     Store = "BabyShop" },
        { Name = "Toy Shop",      Store = "ToyShop" },
    },

    ["Housing"] = {
        { Name = "Your House",    Func = "GoToHome" },
    }
}

--========================================================--
--               INTERNAL TELEPORT WRAPPER
--========================================================--

local function TeleportTo(API, entry)
    if entry.Func then
        -- Direct API teleport (MainMap, Neighborhood, Home)
        local fn = API[entry.Func]
        if fn then
            fn()
        else
            warn("Teleport function missing:", entry.Func)
        end

    elseif entry.Store then
        -- Store teleport (Nursery, School, etc.)
        API.GoToStore(entry.Store)

    else
        warn("Invalid teleport entry:", entry.Name)
    end
end

--========================================================--
--               UI CREATION
--========================================================--

function TeleportHub.Init(Tabs, API)
    local tab = Tabs.Teleports

    tab:CreateSection("Teleport Hub")

    -- Info label
    tab:CreateLabel("Select a location to teleport instantly.", "map")

    -- Loop through categories
    for category, list in pairs(Teleports) do
        tab:CreateSection(category)

        for _, entry in ipairs(list) do
            tab:CreateButton({
                Name = entry.Name,
                Callback = function()
                    TeleportTo(API, entry)
                end,
            })
        end
    end

    --========================================================--
    --               REFRESH BUTTON (Future-proof)
    --========================================================--

    tab:CreateDivider()

    tab:CreateButton({
        Name = "Refresh Teleport List",
        Callback = function()
            -- In the future, this can auto-detect new interiors
            print("Teleport list refreshed.")
        end,
    })
end

return TeleportHub
