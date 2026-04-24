--========================================================--
--                 ASTRAL.Core.Teleport
--      Centralized teleport routing for all modules
--========================================================--

local Utils = require(script.Parent.Utils)

local Teleport = {}

--========================================================--
--                 TELEPORT ROUTE MAP
--========================================================--

-- These names match your AdoptMeAPI backend functions:
--   API.GoToMainMap()
--   API.GoToNeighborhood()
--   API.GoToHome()
--   API.GoToStore("Nursery")
--   API.GoToStore("School")
--   etc.

Teleport.Routes = {
    -- Main world teleports
    MainMap      = { type = "world", func = "GoToMainMap" },
    Neighborhood = { type = "world", func = "GoToNeighborhood" },
    Home         = { type = "world", func = "GoToHome" },

    -- Stores / interiors
    Nursery      = { type = "store", store = "Nursery" },
    School       = { type = "store", store = "School" },
    Hospital     = { type = "store", store = "Hospital" },
    Salon        = { type = "store", store = "Salon" },
    PizzaShop    = { type = "store", store = "PizzaShop" },
    BabyShop     = { type = "store", store = "BabyShop" },
    ToyShop      = { type = "store", store = "ToyShop" },
    SkyCastle    = { type = "store", store = "SkyCastle" },
}

--========================================================--
--                 NORMALIZATION
--========================================================--

local function normalize(str)
    return Utils.Normalize(str)
end

--========================================================--
--                 LOOKUP HELPERS
--========================================================--

function Teleport.GetRoute(name)
    if not name then return nil end

    name = normalize(name)

    for key, data in pairs(Teleport.Routes) do
        if normalize(key) == name then
            return data
        end
    end

    return nil
end

function Teleport.Exists(name)
    return Teleport.GetRoute(name) ~= nil
end

--========================================================--
--                 EXECUTION HELPERS
--========================================================--

function Teleport.Execute(API, routeName)
    local route = Teleport.GetRoute(routeName)
    if not route then
        warn("[ASTRAL Teleport] Unknown route:", routeName)
        return
    end

    if route.type == "world" then
        local fn = API[route.func]
        if fn then
            fn()
        else
            warn("[ASTRAL Teleport] Missing API function:", route.func)
        end
        return
    end

    if route.type == "store" then
        API.GoToStore(route.store)
        return
    end

    warn("[ASTRAL Teleport] Invalid route type:", route.type)
end

--========================================================--
--                 AILMENT TELEPORT ROUTING
--========================================================--

-- This is used by AutoNeeds, BabyFarm, AutoEggs, etc.
-- It converts an ailment category into a teleport route.

Teleport.AilmentRoutes = {
    Home     = "Home",
    School   = "School",
    Hospital = "Hospital",
    Salon    = "Salon",
}

function Teleport.FromAilmentCategory(category)
    return Teleport.AilmentRoutes[category]
end

--========================================================--
--                 HIGH-LEVEL HELPERS
--========================================================--

function Teleport.GoHome(API)
    Teleport.Execute(API, "Home")
end

function Teleport.GoMain(API)
    Teleport.Execute(API, "MainMap")
end

function Teleport.GoNeighborhood(API)
    Teleport.Execute(API, "Neighborhood")
end

function Teleport.GoStore(API, storeName)
    Teleport.Execute(API, storeName)
end

--========================================================--
--                 EXPORT
--========================================================--

return Teleport
