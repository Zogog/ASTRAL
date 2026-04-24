--========================================================--
--                 ASTRAL.Core.Inventory
--      Centralized inventory helpers for all modules
--========================================================--

local Utils = require(script.Parent.Utils)

local Inventory = {}

--========================================================--
--                 NORMALIZATION HELPERS
--========================================================--

local function normalize(str)
    return Utils.Normalize(str)
end

local function isMatch(name, query)
    name = normalize(name)
    query = normalize(query)
    return string.find(name, query, 1, true) ~= nil
end

--========================================================--
--                 GENERIC FILTER HELPERS
--========================================================--

function Inventory.FilterItems(items, predicate)
    local result = {}

    for id, data in pairs(items) do
        if predicate(id, data) then
            result[id] = data
        end
    end

    return result
end

function Inventory.CountItems(items, predicate)
    local count = 0

    for id, data in pairs(items) do
        if not predicate or predicate(id, data) then
            count += data.amount or 1
        end
    end

    return count
end

--========================================================--
--                 POTION HELPERS
--========================================================--

-- items format (from API.GetPlayersInventory().items):
-- {
--   ["abc"] = { id = "pet_age_potion", amount = 3, ... },
--   ["xyz"] = { id = "apple", amount = 5, ... },
-- }

function Inventory.GetFirstItemById(items, targetId)
    targetId = normalize(targetId)

    for unique, data in pairs(items) do
        if normalize(data.id) == targetId then
            return unique, data
        end
    end

    return nil, nil
end

function Inventory.GetFirstItemByNameContains(items, query)
    for unique, data in pairs(items) do
        if isMatch(data.id or "", query) then
            return unique, data
        end
    end

    return nil, nil
end

function Inventory.CountItemId(items, targetId)
    targetId = normalize(targetId)

    local total = 0
    for _, data in pairs(items) do
        if normalize(data.id) == targetId then
            total += data.amount or 1
        end
    end

    return total
end

--========================================================--
--                 EGG / PET HELPERS
--========================================================--

-- pets format (from API.GetPlayersInventory().pets):
-- {
--   ["unique1"] = { id = "cracked_egg", properties = {...} },
--   ["unique2"] = { id = "dog", properties = {...} },
-- }

function Inventory.FilterEggs(pets, isEggPredicate)
    local result = {}

    for unique, data in pairs(pets) do
        if isEggPredicate(data) then
            result[unique] = data
        end
    end

    return result
end

function Inventory.FilterPets(pets, isPetPredicate)
    local result = {}

    for unique, data in pairs(pets) do
        if isPetPredicate(data) then
            result[unique] = data
        end
    end

    return result
end

function Inventory.GetRandomKey(map)
    local keys = {}

    for k in pairs(map) do
        table.insert(keys, k)
    end

    if #keys == 0 then
        return nil
    end

    return keys[math.random(1, #keys)]
end

--========================================================--
--                 HIGH-LEVEL HELPERS (API-ORIENTED)
--========================================================--

-- These helpers expect an API object with GetPlayersInventory()

function Inventory.GetItems(API)
    local inv = API.GetPlayersInventory()
    return inv.items or {}
end

function Inventory.GetPets(API)
    local inv = API.GetPlayersInventory()
    return inv.pets or {}
end

function Inventory.GetPotionAmount(API, potionId)
    local items = Inventory.GetItems(API)
    return Inventory.CountItemId(items, potionId)
end

function Inventory.GetFirstPotionUnique(API, potionId)
    local items = Inventory.GetItems(API)
    return Inventory.GetFirstItemById(items, potionId)
end

--========================================================--
--                 EXPORT
--========================================================--

return Inventory
