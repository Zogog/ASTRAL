--========================================================--
--                 ASTRAL.Modules.PetViewer
--        Clean, modular pet viewer for Adopt Me
--========================================================--

local Dropdowns = require(script.Parent.Parent.UI.Dropdowns)
local Utils = require(script.Parent.Parent.Core.Utils)

local PetViewer = {}

--========================================================--
--                 INTERNAL HELPERS
--========================================================--

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

    return pets
end

--========================================================--
--                 UI CREATION
--========================================================--

function PetViewer.Init(Tabs, API)
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")

    local PetListLabel = tab:CreateLabel("Loading pets...", "paw-print")

    -- Scrollable list container
    local PetList = tab:CreateParagraph({
        Title = "Your Pets",
        Content = "Loading...",
    })

    -- Details panel
    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet to view details.",
    })

    -- Equip button
    local EquipButton = tab:CreateButton({
        Name = "Equip Selected Pet",
        Callback = function()
            if PetViewer.SelectedPetId then
                API.EquipPet(PetViewer.SelectedPetId)
            end
        end,
    })

    --========================================================--
    --                 LOAD PETS
    --========================================================--

    local function RefreshPets()
        local pets = BuildPetTable(API)

        if #pets == 0 then
            PetListLabel:Set("You have no pets.")
            PetList:Set({
                Title = "Your Pets",
                Content = "No pets found.",
            })
            return
        end

        PetListLabel:Set("You have " .. #pets .. " pets")

        -- Build dropdown-style list
        local list = Dropdowns.BuildPetList(pets)
        local map = Dropdowns.BuildPetDataMap(pets)

        -- Build display text
        local display = {}
        for i, item in ipairs(list) do
            table.insert(display, item)
        end

        PetList:Set({
            Title = "Your Pets",
            Content = table.concat(display, "\n"),
        })

        -- Store for selection
        PetViewer.PetList = list
        PetViewer.PetMap = map
    end

    RefreshPets()

    --========================================================--
    --                 SEARCH BAR
    --========================================================--

    tab:CreateInput({
        Name = "Search Pets",
        PlaceholderText = "Type a pet name...",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            if not PetViewer.PetList then return end

            if not Utils.IsLetters(text) and text ~= "" then
                PetList:Set({
                    Title = "Your Pets",
                    Content = "Search must contain letters only.",
                })
                return
            end

            local filtered = Dropdowns.Filter(PetViewer.PetList, text)

            if #filtered == 0 then
                PetList:Set({
                    Title = "Your Pets",
                    Content = "No pets match your search.",
                })
                return
            end

            PetList:Set({
                Title = "Your Pets",
                Content = table.concat(filtered, "\n"),
            })
        end,
    })

    --========================================================--
    --                 SELECT PET INPUT
    --========================================================--

    tab:CreateInput({
        Name = "Select Pet (Enter Index)",
        PlaceholderText = "Example: 1",
        RemoveTextAfterFocusLost = true,
        Callback = function(text)
            local index = tonumber(text)
            if not index then return end

            if not PetViewer.PetMap or not PetViewer.PetMap[index] then
                Details:Set({
                    Title = "Pet Details",
                    Content = "Invalid pet index.",
                })
                return
            end

            local pet = PetViewer.PetMap[index]
            PetViewer.SelectedPetId = pet.id

            Details:Set({
                Title = "Pet Details",
                Content = string.format(
                    "Kind: %s\nAge: %d\nID: %s",
                    pet.kind,
                    pet.age,
                    pet.id
                ),
            })
        end,
    })

    --========================================================--
    --                 REFRESH BUTTON
    --========================================================--

    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = function()
            RefreshPets()
        end,
    })
end

return PetViewer
