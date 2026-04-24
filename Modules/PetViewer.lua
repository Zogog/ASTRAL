--========================================================--
--                 ASTRAL.Modules.PetViewer
--========================================================--

local PetViewer = {}

-- Build a clean pet table from inventory
local function BuildPetTable(API)
    local inv = API.GetPlayersInventory().pets
    local pets = {}

    for id, data in pairs(inv) do
        if data.id ~= "practice_dog" then
            table.insert(pets, {
                id = id,
                kind = data.id,
                age = data.properties.age or 0,
            })
        end
    end

    table.sort(pets, function(a, b)
        return a.kind:lower() < b.kind:lower()
    end)

    return pets
end

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local Utils = Core.Utils

    local tab = Tabs.Pets
    tab:CreateSection("Pet Viewer")

    local PetCountLabel = tab:CreateLabel("Loading pets...")

    -- Dropdown reference
    local PetDropdown = nil

    -- Details panel
    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet from the dropdown.",
    })

    -- Lookup table: name → pet data
    local PetLookup = {}

    ------------------------------------------------------------
    -- Refresh function (rebuilds dropdown)
    ------------------------------------------------------------
    local function RefreshPets()
        local pets = BuildPetTable(API)

        if #pets == 0 then
            PetCountLabel:Set("You have no pets.")
            if PetDropdown then
                PetDropdown:Set({ Options = {} })
            end
            return
        end

        PetCountLabel:Set("You have " .. #pets .. " pets")

        -- Build dropdown options
        local options = {}
        PetLookup = {}

        for _, pet in ipairs(pets) do
            local display = string.format("%s (Age %d)", pet.kind, pet.age)
            table.insert(options, display)
            PetLookup[display] = pet
        end

        -- Create dropdown if not created yet
        if not PetDropdown then
            PetDropdown = tab:CreateDropdown({
                Name = "Select a Pet",
                Options = options,
                Callback = function(selected)
                    local pet = PetLookup[selected]
                    if not pet then return end

                    -- Equip instantly
                    API.EquipPet(pet.id)

                    -- Update details panel
                    Details:Set({
                        Title = "Pet Details",
                        Content = string.format(
                            "Kind: %s\nAge: %d\nID: %s\n\nEquipped!",
                            pet.kind,
                            pet.age,
                            pet.id
                        ),
                    })
                end,
            })
        else
            -- Update existing dropdown
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
        Callback = function()
            RefreshPets()
        end,
    })
end

return PetViewer
