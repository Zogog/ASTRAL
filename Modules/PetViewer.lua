--========================================================--
--                 ASTRAL.Modules.PetViewer
--     Fully Patched – TBIGUI Style – Full UID – v2
--========================================================--

local PetViewer = {}

-- Age names
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

local function GetAgeName(props)
    local age = props.age or 1
    if props.is_neon or props.is_mega_neon then
        return NEON_AGES[age] or "Unknown"
    end
    return NORMAL_AGES[age] or "Unknown"
end

local function GetEmoji(props)
    if props.is_mega_neon then return "🌈" end
    if props.is_neon then return "✨" end
    return ""
end

--========================================================--
-- INIT
--========================================================--

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")

    local PetListLabel = tab:CreateLabel("Loading pets...", "paw-print")

    --------------------------------------------------------
    -- Dropdown (TBIGUI-style string options)
    --------------------------------------------------------

    local Dropdown = tab:CreateDropdown({
        Name = "Select Pet",
        Options = { "None" },
        CurrentOption = "None", -- IMPORTANT FIX
        MultipleOptions = false,

        Callback = function(option)
            -- Rayfield sometimes passes { "string" }
            if type(option) == "table" then
                -- If Rayfield passed its internal multi-select object, ignore
                if option.Set ~= nil then
                    return
                end
                option = option[1]
            end

            if not option or option == "None" then return end

            -- Extract FULL UID from TBIGUI-style string
            -- Format: "index=kind: AgeName -- FULLUID"
            local uid = option:match("%-%-%s*(.+)$")
            if not uid then
                warn("[PetViewer] Failed to extract UID from:", option)
                return
            end

            local pet = PetViewer.Map[uid]
            if not pet then
                warn("[PetViewer] No pet found for UID:", uid)
                return
            end

            PetViewer.Selected = pet

            Details:Set({
                Title = "Pet Details",
                Content = string.format(
                    "Kind: %s\nAge: %s\nID: %s",
                    pet.kind,
                    GetAgeName(pet.properties),
                    pet.id
                ),
            })

            -- Equip immediately (FULL UID)
            if API.EquipPet then
                API.EquipPet(uid)
            elseif Core.SetEquippedPet then
                Core.SetEquippedPet(uid)
            end
        end,
    })

    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet to view details.",
    })

    --------------------------------------------------------
    -- Sorting
    --------------------------------------------------------

    local SortMode = "A-Z"

    tab:CreateDropdown({
        Name = "Sort By",
        Options = { "A-Z", "Age", "Neon", "Mega" },
        CurrentOption = "A-Z",
        Callback = function(opt)
            SortMode = opt
            PetViewer.Refresh()
        end,
    })

    --------------------------------------------------------
    -- Search
    --------------------------------------------------------

    tab:CreateInput({
        Name = "Search Pets",
        PlaceholderText = "Type a pet name...",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            PetViewer.SearchText = text:lower()
            PetViewer.Refresh()
        end,
    })

    --------------------------------------------------------
    -- Load Pets
    --------------------------------------------------------

    local function LoadPets()
        local inv = API.GetPlayersInventory()
        if not inv or not inv.pets then
            PetListLabel:Set("No pets found.")
            return
        end

        local pets = {}
        local map = {}

        for uid, data in pairs(inv.pets) do
            if data.id ~= "practice_dog" then
                local pet = {
                    id = uid,
                    kind = data.id,
                    properties = data.properties or {},
                }

                table.insert(pets, pet)
                map[uid] = pet
            end
        end

        PetViewer.All = pets
        PetViewer.Map = map

        PetViewer.Refresh()
    end

    --------------------------------------------------------
    -- Refresh Logic (TBIGUI-style strings)
    --------------------------------------------------------

    function PetViewer.Refresh()
        if not PetViewer.All then return end

        local list = {}
        local search = PetViewer.SearchText or ""

        -- Filter
        for _, pet in ipairs(PetViewer.All) do
            if pet.kind:lower():find(search) then
                table.insert(list, pet)
            end
        end

        -- Sort
        if SortMode == "A-Z" then
            table.sort(list, function(a, b)
                return a.kind < b.kind
            end)
        elseif SortMode == "Age" then
            table.sort(list, function(a, b)
                return (a.properties.age or 1) > (b.properties.age or 1)
            end)
        elseif SortMode == "Neon" then
            table.sort(list, function(a, b)
                return (a.properties.is_neon and 1 or 0) >
                       (b.properties.is_neon and 1 or 0)
            end)
        elseif SortMode == "Mega" then
            table.sort(list, function(a, b)
                return (a.properties.is_mega_neon and 1 or 0) >
                       (b.properties.is_mega_neon and 1 or 0)
            end)
        end

        -- Build TBIGUI-style dropdown list (FULL UID)
        local display = {}

        for index, pet in ipairs(list) do
            local props = pet.properties
            local label = string.format(
                "%d=%s: %s -- %s",
                index,
                pet.kind,
                GetAgeName(props),
                pet.id  -- FULL UID
            )

            table.insert(display, label)
        end

        -- Prevent Rayfield corruption
        if #display == 0 then
            display = { "None" }
        end

        Dropdown:Refresh(display)

        PetListLabel:Set("You have " .. tostring(#list) .. " pets")
    end

    --------------------------------------------------------
    -- Initial Load
    --------------------------------------------------------

    LoadPets()

    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = LoadPets,
    })
end

return PetViewer
