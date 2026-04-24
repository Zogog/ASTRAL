--========================================================--
--                 ASTRAL.Core.Pets
--      Centralized pet logic for all modules
--========================================================--

local Utils = require(script.Parent.Utils)

local Pets = {}

--========================================================--
--                 NORMALIZATION HELPERS
--========================================================--

local function normalize(str)
    return Utils.Normalize(str)
end

--========================================================--
--                 PET TYPE HELPERS
--========================================================--

function Pets.IsEgg(petData)
    if not petData or not petData.id then
        return false
    end

    local id = normalize(petData.id)
    return id:find("egg") ~= nil
end

function Pets.IsPet(petData)
    return not Pets.IsEgg(petData)
end

--========================================================--
--                 AGE HELPERS
--========================================================--

-- Age scale: 0–6 (6 = full grown)
function Pets.IsFullGrown(petData)
    if not petData or not petData.properties then
        return false
    end

    local age = petData.properties.age or 0
    return age >= 6
end

function Pets.GetAge(petData)
    if not petData or not petData.properties then
        return 0
    end

    return petData.properties.age or 0
end

--========================================================--
--                 KIND HELPERS
--========================================================--

function Pets.GetKind(petData)
    if not petData then return nil end
    return petData.id
end

function Pets.IsSameKind(petA, petB)
    if not petA or not petB then return false end
    return normalize(petA.id) == normalize(petB.id)
end

--========================================================--
--                 FILTER HELPERS
--========================================================--

function Pets.Filter(pets, predicate)
    local result = {}

    for unique, data in pairs(pets) do
        if predicate(unique, data) then
            result[unique] = data
        end
    end

    return result
end

function Pets.FilterEggs(pets)
    return Pets.Filter(pets, function(_, data)
        return Pets.IsEgg(data)
    end)
end

function Pets.FilterPets(pets)
    return Pets.Filter(pets, function(_, data)
        return Pets.IsPet(data)
    end)
end

function Pets.FilterByKind(pets, kind)
    kind = normalize(kind)

    return Pets.Filter(pets, function(_, data)
        return normalize(data.id) == kind
    end)
end

--========================================================--
--                 SORTING HELPERS
--========================================================--

function Pets.SortAlphabetical(pets)
    local list = {}

    for unique, data in pairs(pets) do
        table.insert(list, { unique = unique, data = data })
    end

    table.sort(list, function(a, b)
        return normalize(a.data.id) < normalize(b.data.id)
    end)

    return list
end

function Pets.SortByAge(pets)
    local list = {}

    for unique, data in pairs(pets) do
        table.insert(list, { unique = unique, data = data })
    end

    table.sort(list, function(a, b)
        return Pets.GetAge(a.data) < Pets.GetAge(b.data)
    end)

    return list
end

--========================================================--
--                 RANDOM SELECTION
--========================================================--

function Pets.GetRandom(pets)
    local keys = {}

    for unique in pairs(pets) do
        table.insert(keys, unique)
    end

    if #keys == 0 then
        return nil
    end

    return keys[math.random(1, #keys)]
end

function Pets.GetRandomSameKind(pets, kind)
    local filtered = Pets.FilterByKind(pets, kind)
    return Pets.GetRandom(filtered)
end

--========================================================--
--                 HIGH-LEVEL HELPERS (API-ORIENTED)
--========================================================--

-- These helpers expect an API object with GetPlayersInventory()

function Pets.GetAll(API)
    local inv = API.GetPlayersInventory()
    return inv.pets or {}
end

function Pets.GetEggs(API)
    return Pets.FilterEggs(Pets.GetAll(API))
end

function Pets.GetNonEggs(API)
    return Pets.FilterPets(Pets.GetAll(API))
end

function Pets.GetSameKind(API, exclude1, exclude2, kind)
    local pets = Pets.GetAll(API)
    local filtered = Pets.FilterByKind(pets, kind)

    -- Remove excluded pets
    filtered[exclude1] = nil
    filtered[exclude2] = nil

    return Pets.GetRandom(filtered)
end

function Pets.GetRandomKind(API, unique)
    local pets = Pets.GetAll(API)
    local data = pets[unique]

    if not data then return nil end

    local kind = data.id
    return Pets.GetRandomSameKind(pets, kind)
end

--========================================================--
--                 EXPORT
--========================================================--

return Pets
