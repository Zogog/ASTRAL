--========================================================--
--                 ASTRAL.Modules.PetViewer
--        Sirius Rayfield Compatible + Safe Debug
--========================================================--

local PetViewer = {}

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

local function IsNeon(p) return p and (p.is_neon or p.neon) end
local function IsMega(p) return p and (p.is_mega_neon or p.mega_neon) end

local function GetAgeName(p)
    local age = (p and p.age) or 1
    return (IsNeon(p) or IsMega(p)) and NEON_AGES[age] or NORMAL_AGES[age]
end

local function GetPetEmoji(p)
    if IsMega(p) then return "🌈 " end
    if IsNeon(p) then return "✨ " end
    return ""
end

local function BuildPetTable(API)
    local inv = API.GetPlayersInventory().pets
    local pets = {}
    for uid, data in pairs(inv) do
        if data.kind ~= "practice_dog" then
            table.insert(pets, { id = uid, kind = data.kind, properties = data.properties })
        end
    end
    return pets
end

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")

    local PetCountLabel = tab:CreateLabel("Loading pets...")
    local Details = tab:CreateParagraph({ Title = "Pet Details", Content = "Select a pet." })

    local PetDropdown = nil
    local PetLookup = {}
    local FullPetList = {}

    local CurrentSearch = ""
    local SortMode = "Alphabetical"
    local NeonOnly = false

    local function SortPets(list)
        if SortMode == "Alphabetical" then
            table.sort(list, function(a,b) return a.kind:lower() < b.kind:lower() end)

        elseif SortMode == "Age (Young → Old)" then
            table.sort(list, function(a,b) return (a.properties.age or 0) < (b.properties.age or 0) end)

        elseif SortMode == "Age (Old → Young)" then
            table.sort(list, function(a,b) return (a.properties.age or 0) > (b.properties.age or 0) end)

        elseif SortMode == "Neon/Mega First" then
            table.sort(list, function(a,b)
                local A = IsMega(a.properties) and 2 or IsNeon(a.properties) and 1 or 0
                local B = IsMega(b.properties) and 2 or IsNeon(b.properties) and 1 or 0
                if A == B then return a.kind:lower() < b.kind:lower() end
                return A > B
            end)
        end
        return list
    end

    local function BuildOptions()
        local filtered = {}
        for _, pet in ipairs(FullPetList) do
            local props = pet.properties

            if NeonOnly and not (IsNeon(props) or IsMega(props)) then continue end
            if CurrentSearch ~= "" and not pet.kind:lower():find(CurrentSearch) then continue end

            table.insert(filtered, pet)
        end

        filtered = SortPets(filtered)

        local options = {}
        PetLookup = {}

        for _, pet in ipairs(filtered) do
            local props = pet.properties
            local display = string.format("%s%s (%s) — %s",
                GetPetEmoji(props),
                pet.kind,
                GetAgeName(props),
                pet.id
            )
            table.insert(options, display)
            PetLookup[display] = pet
        end

        return options
    end

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

                    local ok, err = pcall(function()
                        API.EquipPet(pet.id)
                    end)

                    Details:Set({
                        Title = "Pet Details",
                        Content = string.format(
                            "Kind: %s\nAge: %s\nID: %s\nNeon: %s\nMega: %s\nEquip: %s",
                            pet.kind,
                            GetAgeName(pet.properties),
                            pet.id,
                            tostring(IsNeon(pet.properties)),
                            tostring(IsMega(pet.properties)),
                            ok and "Success" or err
                        ),
                    })
                end,
            })

            --------------------------------------------------------
            -- ⭐ DEBUGGER: PRINT ALL METHODS ON THE DROPDOWN OBJECT
            --------------------------------------------------------
            print("\n[DEBUG] Dropdown methods:")
            for k, v in pairs(PetDropdown) do
                print("   ", k, typeof(v))
            end
            print("[DEBUG] End of dropdown method list\n")

        else
            -- DO NOT CALL ANY METHOD YET — we need debugger output first
            print("[DEBUG] RefreshPets called — dropdown exists, but update disabled until debugger output is known.")
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
    -- SORTING
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
    -- NEON FILTER
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
            print("[DEBUG] Get Equipped Pet pressed — waiting for dropdown method list first.")
        end,
    })

    RefreshPets()
end

return PetViewer
