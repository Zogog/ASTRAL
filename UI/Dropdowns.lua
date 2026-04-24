--========================================================--
--                 ASTRAL.UI.Dropdowns
--     Shared dropdown builders + filtering utilities
--========================================================--

local Dropdowns = {}

local Utils -- will be injected

function Dropdowns.SetDependencies(Core)
    Utils = Core.Utils
end

--========================================================--
--     BUILD A GENERIC DROPDOWN LIST FROM PET DATA
--========================================================--

function Dropdowns.BuildPetList(petsTable)
    local list = {}

    table.sort(petsTable, function(a, b)
        local nameA = a.kind:lower()
        local nameB = b.kind:lower()

        if nameA == nameB then
            return Utils.NaturalSort(a.id, b.id)
        end

        return nameA < nameB
    end)

    for index, pet in ipairs(petsTable) do
        list[index] = string.format(
            "%d=%s: %d -- %s",
            index,
            pet.kind,
            pet.age,
            Utils.FirstSix(pet.id)
        )
    end

    return list
end

--========================================================--
--     FILTER A DROPDOWN LIST BY SEARCH TEXT
--========================================================--

function Dropdowns.Filter(list, search)
    if not search or search == "" then
        return list
    end

    local normalized = Utils.Normalize(search)
    local results = {}

    for _, item in ipairs(list) do
        if string.find(item:lower(), normalized) then
            table.insert(results, item)
        end
    end

    return results
end

--========================================================--
--     EXTRACT PET INDEX FROM DROPDOWN STRING
--========================================================--

function Dropdowns.GetIndexFromOption(option)
    return Utils.NumberBeforeEqual(option)
end

--========================================================--
--     EXTRACT PET ID FROM PET DATA MAP
--========================================================--

function Dropdowns.GetPetIdFromMap(petDataMap, index)
    local entry = petDataMap[index]
    return entry and entry.id or nil
end

--========================================================--
--     BUILD PET DATA MAP (INDEX → PET INFO)
--========================================================--

function Dropdowns.BuildPetDataMap(petsTable)
    local map = {}

    for index, pet in ipairs(petsTable) do
        map[index] = {
            id   = pet.id,
            kind = pet.kind,
            age  = pet.age,
        }
    end

    return map
end

return Dropdowns
