--========================================================--
--                 ASTRAL.Modules.PetViewer
--        Final Sirius Rayfield Compatible Version
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
    local FullPetList = {}

    PetViewer.SelectedPetId = nil

    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet from the dropdown.",
    })

    --------------------------------------------------------
    -- FILTERS
    --------------------------------------------------------
    local CurrentSearch = ""
    local SortMode = "Alphabetical"
    local NeonOnly = false

    --------------------------------------------------------
    -- SORTING FUNCTION
    --------------------------------------------------------
    local function SortPets(list)
        if SortMode == "Alphabetical" then
            table.sort(list, function(a, b)
                return a.kind:lower() < b.kind:lower()
            end)

        elseif SortMode == "Age (Young → Old)" then
            table.sort(list, function(a, b)
                return (a.properties.age or 0) < (b.properties.age or 0)
            end)

        elseif SortMode == "Age (Old → Young)" then
            table.sort(list, function(a, b)
                return (a.properties.age or 0) > (b.properties.age or 0)
            end)

        elseif SortMode == "Neon/Mega First" then
            table.sort(list, function(a, b)
                local A = (IsMega(a.properties) and 2) or (IsNeon(a.properties) and 1) or 0
                local B = (IsMega(b.properties) and 2) or (IsNeon(b.properties) and 1) or 0
                if A == B then
                    return a.kind:lower() < b.kind:lower()
                end
                return A > B
            end)
        end

        return list
    end

    --------------------------------------------------------
    -- APPLY FILTERS + BUILD OPTIONS
    --------------------------------------------------------
    local function BuildOptions()
        local filtered = {}

        for _, pet in ipairs(FullPetList) do
            local props = pet.properties

            if NeonOnly and not (IsNeon(props) or IsMega(props)) then
                continue
            end

            if CurrentSearch ~= "" and not pet.kind:lower():find(CurrentSearch) then
                continue
            end

            table.insert(filtered, pet)
        end

        filtered = SortPets(filtered)

        local options = {}
        PetLookup = {}

        for _, pet in ipairs(filtered) do
            local props = pet.properties
            local emoji = GetPetEmoji(props)
            local ageName = GetAgeName(props)

            local display = string.format("%s%s (%s) — %s", emoji, pet.kind, ageName, pet.id)

            table.insert(options, display)
            PetLookup[display] = pet
        end

        return options
    end

    --------------------------------------------------------
    -- REFRESH PET LIST
    --------------------------------------------------------
    local function RefreshPets()
        FullPetList = BuildPetTable(API)
        PetCountLabel:Set("You have " .. #FullPetList .. " pets")

        local options = BuildOptions()

        if not PetDropdown then
            PetDropdown = tab:CreateDropdown({
                Name = "Select a Pet",
                Options = options,
                CurrentOption = { options[1] or "None" },
                MultipleOptions = false,

                Callback = function(_)
                    local selected = PetDropdown.CurrentOption and PetDropdown.CurrentOption[1]

                    if typeof(selected) ~= "string" then return end

                    local pet = PetLookup[selected]
                    if not pet then return end

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
    -- SEARCH BAR
    --------------------------------------------------------
    tab:CreateInput({
        Name = "Search Pets",
        PlaceholderText = "Type a pet name...",
        RemoveTextAfterFocusLost = false,

        Callback = function(text)
            CurrentSearch = text:lower()
            RefreshPets()
        end,
    })

    --------------------------------------------------------
    -- SORTING DROPDOWN
    --------------------------------------------------------
    tab:CreateDropdown({
        Name = "Sort By",
        Options = {
            "Alphabetical",
            "Age (Young → Old)",
            "Age (Old → Young)",
            "Neon/Mega First",
        },
        CurrentOption = { "Alphabetical" },

        Callback = function(opt)
            SortMode = opt[1]
            RefreshPets()
        end,
    })

    --------------------------------------------------------
    -- NEON/MEGA FILTER
    --------------------------------------------------------
    tab:CreateToggle({
        Name = "Show Only Neon/Mega",
        CurrentValue = false,

        Callback = function(state)
            NeonOnly = state
            RefreshPets()
        end,
    })

    --------------------------------------------------------
    -- GET CURRENTLY EQUIPPED PET
    --------------------------------------------------------
    tab:CreateButton({
        Name = "Get Currently Equipped Pet",

        Callback = function()
    local equipped = API.GetEquippedPets()
    local uid = nil

    -- Case 1: API returns { [1] = {id=...}, [2] = {...} }
    if typeof(equipped) == "table" and equipped[1] and equipped[1].id then
        uid = equipped[1].id

    -- Case 2: API returns { primary = {id=...}, secondary = {...} }
    elseif typeof(equipped) == "table" and equipped.primary and equipped.primary.id then
        uid = equipped.primary.id

    -- Case 3: API returns a single pet object
    elseif typeof(equipped) == "table" and equipped.id then
        uid = equipped.id
    end

    if not uid then
        Details:Set({
            Title = "Pet Details",
            Content = "No equipped pet found.",
        })
        return
    end

    -- Find matching dropdown entry
    for display, pet in pairs(PetLookup) do
        if pet.id == uid then
            -- Select it in the dropdown
            PetDropdown:Set({ CurrentOption = { display } })
            PetViewer.SelectedPetId = uid

            -- Update details panel
            Details:Set({
                Title = "Pet Details",
                Content = string.format(
                    "Kind: %s\nAge: %s\nID: %s\nNeon: %s\nMega: %s",
                    pet.kind,
                    GetAgeName(pet.properties),
                    pet.id,
                    tostring(IsNeon(pet.properties)),
                    tostring(IsMega(pet.properties))
                ),
            })

            return
        end
    end

    Details:Set({
        Title = "Pet Details",
        Content = "Equipped pet not found in filtered list.",
    })
end

    --------------------------------------------------------
    -- INITIAL LOAD
    --------------------------------------------------------
    RefreshPets()
end

return PetViewer
