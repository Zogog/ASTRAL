--========================================================--
--                    ASTRAL.Main (TBIGUI API)
--========================================================--

local Main = {}

-- Age tables (same as PetViewer)
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
    return props and (props.is_neon or props.neon)
end

local function IsMega(props)
    return props and (props.is_mega_neon or props.mega_neon)
end

local function GetAgeName(props)
    local age = (props and props.age) or 1
    return (IsNeon(props) or IsMega(props)) and NEON_AGES[age] or NORMAL_AGES[age]
end

local function GetPetEmoji(props)
    if IsMega(props) then return "🌈 " end
    if IsNeon(props) then return "✨ " end
    return ""
end

--========================================================--
-- INIT
--========================================================--

function Main.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local tab = Tabs.Main

    tab:CreateSection("ASTRAL Status")

    --------------------------------------------------------
    -- RUNTIME
    --------------------------------------------------------
    local StartTime = tick()

    local RuntimeLabel = tab:CreateLabel("Runtime: 00:00:00")

    task.spawn(function()
        while task.wait(1) do
            local elapsed = tick() - StartTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = math.floor(elapsed % 60)
            RuntimeLabel:Set(string.format("Runtime: %02d:%02d:%02d", h, m, s))
        end
    end)

    --------------------------------------------------------
    -- BUCKS
    --------------------------------------------------------
    local BucksLabel = tab:CreateLabel("Bucks: Loading...")

    task.spawn(function()
        while task.wait(1) do
            local bucks = API.GetPlayerMoney and API.GetPlayerMoney() or 0
            BucksLabel:Set("Bucks: " .. tostring(bucks))
        end
    end)

    --------------------------------------------------------
    -- POTIONS (Age Potions Only)
    --------------------------------------------------------
    local PotionsLabel = tab:CreateLabel("Age Potions: Loading...")

    local function CountAgePotions()
        local inv = API.GetPlayersInventory and API.GetPlayersInventory()
        if not inv or not inv.food then return 0 end

        local count = 0
        for _, item in pairs(inv.food) do
            if item.kind == "pet_age_potion" then
                count += 1
            end
        end
        return count
    end

    task.spawn(function()
        while task.wait(2) do
            PotionsLabel:Set("Age Potions: " .. CountAgePotions())
        end
    end)

    --------------------------------------------------------
    -- EQUIPPED PET (Tracked via ASTRAL, not API)
    --------------------------------------------------------
    local EquippedLabel = tab:CreateLabel("Equipped Pet: None")

    task.spawn(function()
        while task.wait(1) do
            local id = Core.EquippedPetID  -- ASTRAL sets this when equipping pets
            if not id then
                EquippedLabel:Set("Equipped Pet: None")
                continue
            end

            local inv = API.GetPlayersInventory and API.GetPlayersInventory()
            if not inv or not inv.pets then
                EquippedLabel:Set("Equipped Pet: None")
                continue
            end

            local pet = inv.pets[id]
            if not pet then
                EquippedLabel:Set("Equipped Pet: None")
                continue
            end

            local props = pet.properties
            local emoji = GetPetEmoji(props)
            local age = GetAgeName(props)

            EquippedLabel:Set(string.format(
                "Equipped Pet: %s%s (%s)",
                emoji,
                pet.kind,
                age
            ))
        end
    end)

    --------------------------------------------------------
    -- ASTRAL sets this when equipping pets
    --------------------------------------------------------
    Core.SetEquippedPet = function(petId)
        Core.EquippedPetID = petId
    end
end

return Main
