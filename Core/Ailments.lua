--========================================================--
--                 ASTRAL.Core.Ailments
--      Centralized ailment logic for all modules
--========================================================--

local Utils = require(script.Parent.Utils)

local Ailments = {}

--========================================================--
--                 NORMALIZATION
--========================================================--

local function Normalize(ailment)
    if not ailment then return nil end
    return Utils.Normalize(ailment)
end

--========================================================--
--                 AILMENT ROUTING MAP
--========================================================--

-- This table defines where each ailment should be solved.
-- Modules can use this to decide where to teleport.
Ailments.Routes = {
    hungry   = "Home",
    thirsty  = "Home",
    sleepy   = "Home",
    dirty    = "Home",

    school   = "School",
    hospital = "Hospital",
    salon    = "Salon",

    -- Future ailments can be added here
}

--========================================================--
--                 AILMENT CATEGORIES
--========================================================--

Ailments.Categories = {
    Home = {
        hungry = true,
        thirsty = true,
        sleepy = true,
        dirty = true,
    },

    School = {
        school = true,
    },

    Hospital = {
        hospital = true,
    },

    Salon = {
        salon = true,
    },
}

--========================================================--
--                 PUBLIC HELPERS
--========================================================--

-- Returns the normalized ailment name
function Ailments.NormalizeAilment(ailment)
    return Normalize(ailment)
end

-- Returns the category (Home, School, Hospital, Salon)
function Ailments.GetCategory(ailment)
    ailment = Normalize(ailment)
    if not ailment then return nil end

    for category, list in pairs(Ailments.Categories) do
        if list[ailment] then
            return category
        end
    end

    return nil
end

-- Returns the recommended teleport location
function Ailments.GetRoute(ailment)
    ailment = Normalize(ailment)
    return Ailments.Routes[ailment]
end

-- Returns true if the ailment is disabled
function Ailments.IsDisabled(ailment, disabledList)
    ailment = Normalize(ailment)
    if not ailment then return true end

    for _, disabled in ipairs(disabledList or {}) do
        if ailment == disabled then
            return true
        end
    end

    return false
end

-- Filters an ailment table based on disabled ailments
function Ailments.FilterAilments(ailmentTable, disabledList)
    local result = {}

    for ailment, value in pairs(ailmentTable) do
        local normalized = Normalize(ailment)
        if not Ailments.IsDisabled(normalized, disabledList) then
            result[normalized] = value
        end
    end

    return result
end

-- Returns true if the ailment requires teleporting
function Ailments.RequiresTeleport(ailment)
    ailment = Normalize(ailment)
    local route = Ailments.Routes[ailment]
    return route ~= nil and route ~= "Home"
end

--========================================================--
--                 EXPORT
--========================================================--

return Ailments
