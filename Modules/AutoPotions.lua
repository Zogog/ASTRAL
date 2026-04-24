--========================================================--
--                 ASTRAL.Modules.AutoPotions
--      Auto-buy + auto-feed age potions to selected pet
--========================================================--

local Settings = require(script.Parent.Parent.UI.Settings)
local Utils = require(script.Parent.Parent.Core.Utils)

local AutoPotions = {}

--========================================================--
--                 INTERNAL STATE
--========================================================--

local running = false
local selectedPet = nil
local autoBuy = false

--========================================================--
--                 LOGGING
--========================================================--

local function Log(msg)
    print("[ASTRAL AutoPotions] " .. msg)
end

local function WaitTick()
    task.wait(Settings.GetTickDelay())
end

--========================================================--
--                 INTERNAL HELPERS
--========================================================--

local function EnsurePetEquipped(API)
    if not selectedPet then return end

    local equipped = API.GetPlayersEquippedPets()
    for _, v in pairs(equipped) do
        if v.unique == selectedPet then
            return
        end
    end

    Log("Equipping pet: " .. selectedPet)
    API.EquipPet(selectedPet)
    WaitTick()
end

local function BuyPotion(API)
    Log("Buying potion...")

    -- Teleport to potion shop
    API.GoToStore("SkyCastle") -- Sky Castle is where potions are sold
    WaitTick()

    -- Buy potion via RouterClient
    API.RunRouterClient(false, "ShopAPI/BuyItem", {
        "pet_age_potion",
        { amount = 1 }
    })

    WaitTick()
end

local function FeedPotion(API)
    Log("Feeding potion to pet...")

    local potionId = API.GetFoodToGive("pet_age_potion")
    if potionId == "" then
        Log("No potion found in inventory")
        return
    end

    API.RunRouterClient(false, "PetAPI/FeedPet", {
        selectedPet,
        potionId
    })

    WaitTick()
end

--========================================================--
--                 MAIN LOOP
--========================================================--

local function StartLoop(API)
    running = true
    Log("AutoPotions started")

    while running do
        task.wait()

        if not selectedPet then
            Log("No pet selected")
            task.wait(1)
            continue
        end

        EnsurePetEquipped(API)

        local potionCount = API.GetPlayerPotionAmount()

        if potionCount == 0 then
            if autoBuy then
                BuyPotion(API)
            else
                Log("No potions left — auto-buy disabled")
                task.wait(2)
                continue
            end
        end

        FeedPotion(API)
        WaitTick()
    end

    Log("AutoPotions stopped")
end

--========================================================--
--                 UI CREATION
--========================================================--

function AutoPotions.Init(Tabs, API)
    local tab = Tabs.Autofarm

    tab:CreateSection("Auto Potions")

    -- Enable toggle
    tab:CreateToggle({
        Name = "Enable Auto Potions",
        CurrentValue = false,
        Callback = function(state)
            if state then
                task.spawn(StartLoop, API)
            else
                running = false
            end
        end,
    })

    -- Pet selection
    tab:CreateInput({
        Name = "Pet Unique ID",
        PlaceholderText = "Enter pet unique ID",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            selectedPet = text ~= "" and text or nil
            if selectedPet then
                Log("Selected pet: " .. selectedPet)
            end
        end,
    })

    -- Auto-buy toggle
    tab:CreateToggle({
        Name = "Auto-Buy Potions",
        CurrentValue = false,
        Callback = function(state)
            autoBuy = state
            Log("Auto-buy potions: " .. tostring(state))
        end,
    })

    -- Stop button
    tab:CreateButton({
        Name = "Force Stop Auto Potions",
        Callback = function()
            running = false
        end,
    })
end

return AutoPotions
