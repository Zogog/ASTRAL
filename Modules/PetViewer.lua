--========================================================--
--                 ASTRAL.Modules.PetViewer
--========================================================--

local PetViewer = {}

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

function PetViewer.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local Utils = Core.Utils
    local Dropdowns = UI.Dropdowns

    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")

    local PetListLabel = tab:CreateLabel("Loading pets...", "paw-print")

    local PetList = tab:CreateParagraph({
        Title = "Your Pets",
        Content = "Loading...",
    })

    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet to view details.",
    })

    tab:CreateButton({
        Name = "Equip Selected Pet",
        Callback = function()
            if PetViewer.SelectedPetId then
                API.EquipPet(PetViewer.SelectedPetId)
            end
        end,
    })

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

        local list = Dropdowns.BuildPetList(pets)
        local map = Dropdowns.BuildPetDataMap(pets)

        local display = {}
        for _, item in ipairs(list) do
            table.insert(display, item)
        end

        PetList:Set({
            Title = "Your Pets",
            Content = table.concat(display, "\n"),
        })

        PetViewer.PetList = list
        PetViewer.PetMap = map
    end

    RefreshPets()

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

    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = function()
            RefreshPets()
        end,
    })
end

return PetViewer
