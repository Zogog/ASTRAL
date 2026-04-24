--========================================================--
--                 ASTRAL.Modules.PetViewer
--========================================================--

local PetViewer = {}

--========================================================--
-- AGE TABLES
--========================================================--

local NORMAL_AGES = {
    [1] = "Newborn",
    [2] = "Junior",
    [3] = "Pre-Teen",
    [4] = "Teen",
    [5] = "Post-Teen",
    [6] = "Full Grown",
}

local NEON_AGES = {
    [1] = "Reborn",
    [2] = "Twinkle",
    [3] = "Sparkle",
    [4] = "Flare",
    [5] = "Sunshine",
    [6] = "Luminous",
}

--========================================================--
-- PROPERTY HELPERS
--========================================================--

local function IsNeon(props)
    return props.is_neon or props.neon
end

local function IsMega(props)
    return props.is_mega_neon or props.mega_neon
end

local function GetAgeName(props)
    local age = props.age or 1

    if IsMega(props) or IsNeon(props) then
        return NEON_AGES[age] or "Unknown"
    else
        return NORMAL_AGES[age] or "Unknown"
    end
end

local function GetPetEmoji(props)
    if IsMega(props) then
        return "🌈 "
    elseif IsNeon(props) then
        return "✨ "
    end
    return ""
end

--========================================================--
-- BUILD PET TABLE
--========================================================--

local function BuildPetTable(API)
    local inv = API.GetPlayersInventory().pets
    local pets = {}

    for id, data in pairs(inv) do
        if data.id ~= "practice_dog" then
            table.insert(pets, {
                id = id,
                kind = data.id,
                properties = data.properties,
            })
        end
    end

    table.sort(pets, function(a, b)
        return a.kind:lower() < b.kind:lower()
    end)

    return pets
end

--========================================================--
-- INIT
--========================================================--

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")

    local PetCountLabel = tab:CreateLabel("Loading pets...")

    local PetDropdown = nil
    local PetLookup = {}

    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet from the dropdown.",
    })

    ------------------------------------------------------------
    -- Refresh function
    ------------------------------------------------------------
    local function RefreshPets()
        local pets = BuildPetTable(API)

        if #pets == 0 then
            PetCountLabel:Set("You have no pets.")
            if PetDropdown then PetDropdown:Set({ Options = {} }) end
            return
        end

        PetCountLabel:Set("You have " .. #pets .. " pets")

        local options = {}
        PetLookup = {}

        for _, pet in ipairs(pets) do
            local props = pet.properties
            local emoji = GetPetEmoji(props)
            local ageName = GetAgeName(props)

            local display = string.format("%s%s (%s)", emoji, pet.kind, ageName)

            table.insert(options, display)
            PetLookup[display] = pet
        end

        if not PetDropdown then
            PetDropdown = tab:CreateDropdown({
                Name = "Select a Pet",
                Options = options,
                Callback = function(selected)
                    local pet = PetLookup[selected]
                    if not pet then return end

                    API.EquipPet(pet.id)

                    Details:Set({
                        Title = "Pet Details",
                        Content = string.format(
                            "Kind: %s\nAge: %s\nID: %s\nNeon: %s\nMega: %s\n\nEquipped!",
                            pet.kind,
                            GetAgeName(pet.properties),
                            pet.id,
                            tostring(IsNeon(pet.properties)),
                            tostring(IsMega(pet.properties))
                        ),
                    })
                end,
            })
        else
            PetDropdown:Set({ Options = options })
        end
    end

    ------------------------------------------------------------
    -- Initial load
    ------------------------------------------------------------
    RefreshPets()

    ------------------------------------------------------------
    -- Refresh button
    ------------------------------------------------------------
    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = RefreshPets,
    })
end

return PetViewer
