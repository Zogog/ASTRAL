--========================================================--
--                 ASTRAL.Modules.PetViewer (DEBUG)
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

local function IsNeon(props)
    return props.is_neon or props.neon
end

local function IsMega(props)
    return props.is_mega_neon or props.mega_neon
end

local function GetAgeName(props)
    local age = props.age or 1
    return (IsMega(props) or IsNeon(props)) and NEON_AGES[age] or NORMAL_AGES[age]
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
        print("[DEBUG] Found pet:", uid, data.kind)
        table.insert(pets, {
            id = uid,
            kind = data.kind,
            properties = data.properties,
        })
    end

    table.sort(pets, function(a, b)
        return a.kind:lower() < b.kind:lower()
    end)

    return pets
end

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer (DEBUG MODE)")

    local PetCountLabel = tab:CreateLabel("Loading pets...")

    local PetDropdown = nil
    local PetLookup = {}

    PetViewer.SelectedPetId = nil

    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet from the dropdown.",
    })

    local function DebugEquip(uid)
        print("\n================ EQUIP DEBUG ================")
        print("Attempting to equip UID:", uid)

        print("Checking RouterClient route exists...")
        local RouterClient = require(game.ReplicatedStorage.ClientModules.Core.RouterClient.RouterClient)
        local route = RouterClient.get("ToolAPI/Equip")
        print("Route:", route)

        print("Calling API.EquipPet...")
        local ok, err = pcall(function()
            API.EquipPet(uid)
        end)

        print("EquipPet pcall result:", ok, err)
        print("=============================================\n")

        return ok, err
    end

    local function RefreshPets()
        local pets = BuildPetTable(API)

        PetCountLabel:Set("You have " .. #pets .. " pets")

        local options = {}
        PetLookup = {}

        for _, pet in ipairs(pets) do
            local props = pet.properties
            local emoji = GetPetEmoji(props)
            local ageName = GetAgeName(props)

            local display = string.format("%s%s (%s) — %s", emoji, pet.kind, ageName, pet.id)

            table.insert(options, display)
            PetLookup[display] = pet
        end

        if not PetDropdown then
            PetDropdown = tab:CreateDropdown({
                Name = "Select a Pet",
                Options = options,
                Callback = function(selected)
                    print("\n[DEBUG] Dropdown selected:", selected)

                    local pet = PetLookup[selected]
                    if not pet then
                        print("[DEBUG] ERROR: Pet not found in lookup table")
                        return
                    end

                    print("[DEBUG] Selected UID:", pet.id)
                    PetViewer.SelectedPetId = pet.id

                    local ok, err = DebugEquip(pet.id)

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
            PetDropdown:Set({ Options = options })
        end
    end

    RefreshPets()

    tab:CreateButton({
        Name = "Equip Selected Pet (DEBUG)",
        Callback = function()
            if not PetViewer.SelectedPetId then
                print("[DEBUG] No pet selected")
                return
            end

            DebugEquip(PetViewer.SelectedPetId)
        end,
    })

    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = RefreshPets,
    })
end

return PetViewer
