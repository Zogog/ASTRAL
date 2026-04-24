--========================================================--
--                 ASTRAL.Modules.PetViewer
--        Sirius Rayfield compatible Pet Viewer
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
-- HELPERS
--========================================================--

local function IsNeon(props)
    return props and (props.is_neon or props.neon)
end

local function IsMega(props)
    return props and (props.is_mega_neon or props.mega_neon)
end

local function GetAgeName(props)
    local age = (props and props.age) or 1
    if IsMega(props) or IsNeon(props) then
        return NEON_AGES[age] or "Unknown"
    else
        return NORMAL_AGES[age] or "Unknown"
    end
end

local function GetPetEmoji(props)
    if IsMega(props) then return "🌈 " end
    if IsNeon(props) then return "✨ " end
    return ""
end

local function BuildPetTable(API)
    local inv = API.GetPlayersInventory().pets
    local pets = {}

    for uid, data in pairs(inv) do
        if data.kind ~= "practice_dog" then
            table.insert(pets, {
                id = uid,
                kind = data.kind,
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

    PetViewer.SelectedPetId = nil

    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet from the dropdown.",
    })

    --------------------------------------------------------
    -- Refresh pet list and rebuild dropdown options
    --------------------------------------------------------
    local function RefreshPets()
        local pets = BuildPetTable(API)

        PetCountLabel:Set("You have " .. #pets .. " pets")

        local options = {}
        PetLookup = {}

        for _, pet in ipairs(pets) do
            local props = pet.properties
            local emoji = GetPetEmoji(props)
            local ageName = GetAgeName(props)

            -- Display string used as key
            local display = string.format("%s%s (%s) — %s", emoji, pet.kind, ageName, pet.id)

            table.insert(options, display)
            PetLookup[display] = pet
        end

        if not PetDropdown then
            ------------------------------------------------
            -- Sirius Rayfield dropdown
            ------------------------------------------------
            PetDropdown = tab:CreateDropdown({
                Name = "Select a Pet",
                Options = options,
                CurrentOption = { options[1] or "None" },
                MultipleOptions = false,

                Callback = function(_)
                    -- In Sirius Rayfield, the real value is in CurrentOption[1]
                    local selected = PetDropdown.CurrentOption and PetDropdown.CurrentOption[1]

                    print("[DEBUG] Selected option:", selected, typeof(selected))

                    if typeof(selected) ~= "string" then
                        warn("[DEBUG] ERROR: Selected option is not a string")
                        return
                    end

                    local pet = PetLookup[selected]
                    if not pet then
                        warn("[DEBUG] ERROR: Pet not found for key:", selected)
                        return
                    end

                    PetViewer.SelectedPetId = pet.id

                    local ok, err = pcall(function()
                        API.EquipPet(pet.id)
                    end)

                    Details:Set({
                        Title = "Pet Details",
                        Content = string.format(
                            "Kind: %s\nAge: %s\nID: %s\nNeon: %s\nMega: %s\n\nEquip Result: %s",
                            pet.kind,
                            GetAgeName(pet.properties),
                            pet.id,
                            tostring(IsNeon(pet.properties)),
                            tostring(IsMega(pet.properties)),
                            ok and "Success" or ("Failed: " .. tostring(err))
                        ),
                    })
                end,
            })
        else
            -- Sirius Rayfield uses :Refresh for options, but :Set with table also works in many forks.
            -- We'll use :Refresh if available, else fallback to :Set.
            if typeof(PetDropdown.Refresh) == "function" then
                PetDropdown:Refresh(options)
            else
                PetDropdown:Set({
                    Options = options,
                    CurrentOption = { options[1] or "None" },
                })
            end
        end
    end

    --------------------------------------------------------
    -- Initial load
    --------------------------------------------------------
    RefreshPets()

    --------------------------------------------------------
    -- Equip Selected Pet button
    --------------------------------------------------------
    tab:CreateButton({
        Name = "Equip Selected Pet",
        Callback = function()
            if not PetViewer.SelectedPetId then
                Details:Set({
                    Title = "Pet Details",
                    Content = "No pet selected.",
                })
                print("[DEBUG] No pet selected")
                return
            end

            local ok, err = pcall(function()
                API.EquipPet(PetViewer.SelectedPetId)
            end)

            Details:Set({
                Title = "Pet Details",
                Content = ok and
                    ("Equipped pet ID: " .. PetViewer.SelectedPetId) or
                    ("Failed to equip: " .. tostring(err)),
            })
        end,
    })

    --------------------------------------------------------
    -- Refresh button
    --------------------------------------------------------
    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = RefreshPets,
    })
end

return PetViewer
