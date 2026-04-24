--========================================================--
--                 ASTRAL.Modules.AutoPotions
--========================================================--

local AutoPotions = {}

local running = false
local selectedPet = nil
local autoBuy = false

local function Log(msg)
    print("[ASTRAL AutoPotions] " .. msg)
end

local function WaitTick(Settings)
    task.wait(Settings.GetTickDelay())
end

local function EnsurePetEquipped(API)
    if not selectedPet then return end

    local equipped = API.GetPlayersEquippedPets()
    for _, v in pairs(equipped) do
        if v.unique == selectedPet then return end
    end

    Log("Equipping pet: " .. selectedPet)
    API.EquipPet(selectedPet)
end

local function BuyPotion(API)
    Log("Buying potion...")
    API.GoToStore("SkyCastle")
    API.RunRouterClient(false, "ShopAPI/BuyItem", {
        "pet_age_potion",
        { amount = 1 }
    })
end

local function FeedPotion(API)
    Log("Feeding potion to pet...")

    local potionId = API.GetFoodToGive("pet_age_potion")
    if potionId == "" then
        Log("No potion found")
        return
    end

    API.RunRouterClient(false, "PetAPI/FeedPet", {
        selectedPet,
        potionId
    })
end

local function StartLoop(API, Core, UI)
    local Settings = UI.Settings

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
        WaitTick(Settings)

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
        WaitTick(Settings)
    end

    Log("AutoPotions stopped")
end

function AutoPotions.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local Settings = UI.Settings

    local tab = Tabs.Autofarm

    tab:CreateSection("Auto Potions")

    tab:CreateToggle({
        Name = "Enable Auto Potions",
        CurrentValue = false,
        Callback = function(state)
            if state then
                task.spawn(StartLoop, API, Core, UI)
            else
                running = false
            end
        end,
    })

    tab:CreateInput({
        Name = "Pet Unique ID",
        PlaceholderText = "Enter pet unique ID",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            selectedPet = text ~= "" and text or nil
            if selectedPet then Log("Selected pet: " .. selectedPet) end
        end,
    })

    tab:CreateToggle({
        Name = "Auto-Buy Potions",
        CurrentValue = false,
        Callback = function(state)
            autoBuy = state
            Log("Auto-buy potions: " .. tostring(state))
        end,
    })

    tab:CreateButton({
        Name = "Force Stop Auto Potions",
        Callback = function()
            running = false
        end,
    })
end

return AutoPotions
