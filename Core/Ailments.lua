--========================================================--
--                 ASTRAL.Core.Ailments
--========================================================--

local Ailments = {}

local function Normalize(ailment)
    if not ailment then return nil end
    return string.lower(tostring(ailment))
end

Ailments.Routes = {
    hungry   = "Home",
    thirsty  = "Home",
    sleepy   = "Home",
    dirty    = "Home",

    school   = "School",
    hospital = "Hospital",
    salon    = "Salon",
}

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

function Ailments.NormalizeAilment(ailment)
    return Normalize(ailment)
end

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

function Ailments.GetRoute(ailment)
    ailment = Normalize(ailment)
    return Ailments.Routes[ailment]
end

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

function Ailments.RequiresTeleport(ailment)
    ailment = Normalize(ailment)
    local route = Ailments.Routes[ailment]
    return route ~= nil and route ~= "Home"
end

return Ailments
