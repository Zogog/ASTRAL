--========================================================--
--                 ASTRAL.Modules.PetViewer
--     TBIGUI-Style – Full UID – v4 (Stable)
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

local function GetAgeName(props)
    local age = props and props.age or 1
    if props and (props.is_mega_neon or props.mega_neon or props.is_neon or props.neon) then
        return NEON_AGES[age] or "Unknown"
    end
    return NORMAL_AGES[age] or "Unknown"
end

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")

    local PetListLabel = tab:CreateLabel("Loading pets...", "paw-print")

    -- create Details FIRST so it's never nil in callback
    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet to view details.",
    })

    --------------------------------------------------------
    -- Dropdown (TBIGUI-style, full UID)
    --------------------------------------------------------

    local Dropdown = tab:CreateDropdown({
        Name = "Select Pet",
        Options = { "None" },
        CurrentOption = { "None" },
        MultipleOptions = false,

        Callback = function(options)
            -- TBIGUI-style: always treat as table
            if type(options) ~= "table" then
                return
            end

            -- get first string value
            local option
            for _, v in pairs(options) do
                if type(v) == "string" then
                    option = v
                    break
                end
            end

            if not option or option == "None" then
                return
            end

            -- "index=kind: AgeName -- FULLUID"
            local uid = option:match("%-%-%s*(.+)$")
            if not uid then
                warn("[PetViewer] Failed to extract UID from:", option)
                return
            end

            local pet = PetViewer.Map and PetViewer.Map[uid]
            if not pet then
                warn("[PetViewer] No pet found for UID:", uid)
                return
            end

            PetViewer.Selected = pet

            -- guard Details in case Rayfield fires super early
            if Details and Details.Set then
                Details:Set({
                    Title = "Pet Details",
                    Content = string.format(
                        "Kind: %s\nAge: %s\nID: %s",
                        pet.kind,
                        GetAgeName(pet.properties),
                        pet.id
                    ),
                })
            end

            if API.EquipPet then
                API.EquipPet(uid)
            elseif Core.SetEquippedPet then
                Core.SetEquippedPet(uid)
            end
        end,
    })

    --------------------------------------------------------
    -- Sorting
    --------------------------------------------------------

    local SortMode = "A-Z"

    tab:CreateDropdown({
        Name = "Sort By",
        Options = { "A-Z", "Age", "Neon", "Mega" },
        CurrentOption = "A-Z",
        MultipleOptions = false,
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
            PetViewer.SearchText = (text or ""):lower()
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
    -- Refresh
    --------------------------------------------------------

    function PetViewer.Refresh()
        if not PetViewer.All then return end

        local list = {}
        local search = PetViewer.SearchText or ""

        for _, pet in ipairs(PetViewer.All) do
            if pet.kind:lower():find(search) then
                table.insert(list, pet)
            end
        end

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
                local an = (a.properties.is_neon or a.properties.neon) and 1 or 0
                local bn = (b.properties.is_neon or b.properties.neon) and 1 or 0
                return an > bn
            end)
        elseif SortMode == "Mega" then
            table.sort(list, function(a, b)
                local am = (a.properties.is_mega_neon or a.properties.mega_neon) and 1 or 0
                local bm = (b.properties.is_mega_neon or b.properties.mega_neon) and 1 or 0
                return am > bm
            end)
        end

        local display = {}

        for index, pet in ipairs(list) do
            local label = string.format(
                "%d=%s: %s -- %s",
                index,
                pet.kind,
                GetAgeName(pet.properties),
                pet.id
            )
            table.insert(display, label)
        end

        if #display == 0 then
            display = { "None" }
        end

        Dropdown:Refresh(display)
        PetListLabel:Set("You have " .. tostring(#list) .. " pets")
    end

    LoadPets()

    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = LoadPets,
    })
end

return PetViewer
