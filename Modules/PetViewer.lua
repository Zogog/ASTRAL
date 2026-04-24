--========================================================--
--                 ASTRAL.Modules.PetViewer
--     Fully Patched – TBIGUI Style – Full UID – v3
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
    local age = props.age or 1
    if props.is_neon or props.is_mega_neon then
        return NEON_AGES[age] or "Unknown"
    end
    return NORMAL_AGES[age] or "Unknown"
end

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")
    local PetListLabel = tab:CreateLabel("Loading pets...", "paw-print")

    --------------------------------------------------------
    -- Dropdown (ALWAYS returns a table)
    --------------------------------------------------------

    local Dropdown = tab:CreateDropdown({
        Name = "Select Pet",
        Options = { "None" },
        CurrentOption = { "None" }, -- TBIGUI uses table here
        MultipleOptions = false,

        Callback = function(options)
            -- Always treat as table
            if type(options) ~= "table" then
                return
            end

            -- Extract first real string
            local option = nil
            for _, v in pairs(options) do
                if type(v) == "string" then
                    option = v
                    break
                end
            end

            if not option or option == "None" then return end

            -- Extract FULL UID
            local uid = option:match("%-%-%s*(.+)$")
            if not uid then return end

            local pet = PetViewer.Map[uid]
            if not pet then return end

            Details:Set({
                Title = "Pet Details",
                Content = string.format(
                    "Kind: %s\nAge: %s\nID: %s",
                    pet.kind,
                    GetAgeName(pet.properties),
                    pet.id
                ),
            })

            -- Equip
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

        local display = {}

        for index, pet in ipairs(list) do
            local props = pet.properties
            local label = string.format(
                "%d=%s: %s -- %s",
                index,
                pet.kind,
                GetAgeName(props),
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
