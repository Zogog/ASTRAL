--========================================================--
--               ASTRAL.Core.AdoptMeAPI
--        Cleaned + Modular Backend Integration
--========================================================--

local AdoptMeAPI = {}
AdoptMeAPI.__index = AdoptMeAPI

--========================================================--
--                 INTERNAL REFERENCES
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local getiden = getthreadidentity or getidentity
local setiden = setthreadidentity or setidentity

local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
local RouterClient = require(ReplicatedStorage.ClientModules.Core.RouterClient.RouterClient)
local InteriorsM = require(ReplicatedStorage.ClientModules.Core.InteriorsM.InteriorsM)

--========================================================--
--                 UTILITY FUNCTIONS
--========================================================--

function AdoptMeAPI.getLastSegment(path)
    return string.match(path, ".*/(.*)")
end

function AdoptMeAPI.isOnlyLetters(text)
    return text:match("^[A-Za-z]+$") ~= nil
end

function AdoptMeAPI.GetNumberBeforeEqual(text)
    return string.match(text, "^(%d+)")
end

function AdoptMeAPI.GetIdInBracket(id)
    return string.match(id, "%((.-)%)")
end

function AdoptMeAPI.isTableEmpty(t)
    return next(t) == nil
end

function AdoptMeAPI.GetFirstSixLetters(text)
    return string.sub(text, 1, 6)
end

function AdoptMeAPI.extractName(name)
    local exclamationIndex = string.find(name, "!")
    local doubleColonIndex = string.find(name, "::")

    if exclamationIndex then
        return string.sub(name, 1, exclamationIndex - 1)
    elseif doubleColonIndex then
        return string.sub(name, 1, doubleColonIndex - 1)
    else
        return name
    end
end

function AdoptMeAPI.NaturalSort(str1, str2)
    local function padNum(num)
        return ("%09d"):format(tonumber(num) or 0)
    end

    str1 = str1:gsub("(%d+)", padNum)
    str2 = str2:gsub("(%d+)", padNum)
    return str1 < str2
end

--========================================================--
--                 INTERIOR / LOCATION
--========================================================--

function AdoptMeAPI.GetPlayerInterior()
    local HouseInteriors = workspace:FindFirstChild("HouseInteriors")
    if not HouseInteriors then return nil end

    local furnitureFolder = HouseInteriors.furniture:FindFirstChildWhichIsA("Folder")
    if furnitureFolder then
        if string.find(furnitureFolder.Name, LocalPlayer.Name)
        or string.find(HouseInteriors.blueprint:FindFirstChildWhichIsA("Model").Name, LocalPlayer.Name) then
            return "House"
        end
    end

    local interiorModel = workspace.Interiors:FindFirstChildWhichIsA("Model")
    if interiorModel then
        return AdoptMeAPI.extractName(interiorModel.Name)
    end

    return nil
end

function AdoptMeAPI.GetCurrentInterior()
    return InteriorsM.get_current_location().destination_id
end

--========================================================--
--                 PLAYER DATA
--========================================================--

function AdoptMeAPI.GetPlayersInventory()
    return ClientData.get_data()[LocalPlayer.Name].inventory
end

function AdoptMeAPI.GetPlayerMoney()
    return ClientData.get_data()[LocalPlayer.Name].money
end

function AdoptMeAPI.GetHouseInterior()
    return ClientData.get_server(LocalPlayer, "house_interior").player
end

function AdoptMeAPI.GetAilmentsManager()
    return ClientData.get_server(LocalPlayer, "ailments_manager")
end

function AdoptMeAPI.GetCertificate()
    return ClientData.get("subscription_manager").equip_2x_pets.active
end

--========================================================--
--                 TELEPORTATION
--========================================================--

local Location
for _, v in next, getgc() do
    if type(v) == "function"
    and islclosure(v)
    and table.find(getconstants(v), "LocationAPI/SetLocation") then
        Location = v
        break
    end
end

local function SetLocation(A, B, C)
    local old = getiden()
    setiden(2)
    Location(A, B, C)
    setiden(old)
end

local function GetInteriorModel()
    return workspace.Interiors:FindFirstChildWhichIsA("Model")
end

local function Store()
    local model = GetInteriorModel()
    return (model and not model.Name:find("MainMap") and not model.Name:find("Neighborhood")) and model.Name or false
end

local function Home()
    local model = workspace.HouseInteriors.blueprint:FindFirstChildWhichIsA("Model")
    return model and model.Name or false
end

local function MainMap()
    local model = GetInteriorModel()
    return (model and model.Name:find("MainMap")) and model.Name or false
end

local function Neighborhood()
    local model = GetInteriorModel()
    return (model and model.Name:find("Neighborhood")) and model.Name or false
end

local function TeleportAndWait(LocationName, Door, Params)
    SetLocation(LocationName, Door, Params)
    return true
end

function AdoptMeAPI.GoToStore(Name)
    if Store() == Name then return true end
    return TeleportAndWait(Name, "MainDoor", {})
end

function AdoptMeAPI.GoToMainMap()
    return TeleportAndWait("MainMap", "Neighborhood/MainDoor", {})
end

function AdoptMeAPI.GoToHome()
    return TeleportAndWait("housing", "MainDoor", { house_owner = LocalPlayer })
end

function AdoptMeAPI.GoToNeighborhood()
    return TeleportAndWait("Neighborhood", "MainDoor", {})
end

--========================================================--
--                 ROUTER CLIENT
--========================================================--

function AdoptMeAPI.RunRouterClient(IsFire, RouterName, args)
    local old = getiden()
    setiden(2)

    local router = RouterClient.get(RouterName)

    if IsFire then
        if args then router:FireServer(unpack(args)) else router:FireServer() end
    else
        if args then router:InvokeServer(unpack(args)) else router:InvokeServer() end
    end

    setiden(old)
end

--========================================================--
--                 PETS
--========================================================--

function AdoptMeAPI.GetPlayersPetConfigs(PetUnique)
    local inv = AdoptMeAPI.GetPlayersInventory().pets
    local cfg = { petKind = "", petAge = 1 }

    for id, data in pairs(inv) do
        if id == PetUnique then
            cfg.petKind = data.kind or ""
            cfg.petAge = data.properties.age or 1
            break
        end
    end

    return cfg
end

function AdoptMeAPI.GetPetConfigs(PetKind)
    local db = AdoptMeAPI.InventoryDB().pets
    local cfg = { isEgg = false }

    for kind, data in pairs(db) do
        if kind == PetKind then
            cfg.isEgg = data.is_egg or false
            break
        end
    end

    return cfg
end

function AdoptMeAPI.GetPlayersEquippedPets()
    return ClientData.get_data()[LocalPlayer.Name].equip_manager.pets
end

function AdoptMeAPI.GetCurrentPet(PetUnique)
    for _, entity in next, AdoptMeAPI.GetPetPetEntityManager().get_local_owned_pet_entities() do
        if string.find(entity.unique_id, PetUnique, 1, true) then
            return entity
        end
    end
    return {}
end

function AdoptMeAPI.EquipPet(PetUnique, AsLast)
    AdoptMeAPI.RunRouterClient(false, "ToolAPI/Equip", {
        PetUnique,
        { equip_as_last = AsLast or false, use_sound_delay = false }
    })
end

function AdoptMeAPI.UnequipPet(PetUnique, AsLast)
    AdoptMeAPI.RunRouterClient(false, "ToolAPI/Unequip", {
        PetUnique,
        { equip_as_last = AsLast or false, use_sound_delay = false }
    })
end

function AdoptMeAPI.UnequipAllPets()
    for _, v in pairs(AdoptMeAPI.GetPlayersEquippedPets()) do
        if v.unique then
            AdoptMeAPI.UnequipPet(v.unique)
        end
    end
end

--========================================================--
--                 INVENTORY HELPERS
--========================================================--

function AdoptMeAPI.GetPlayerPotionAmount()
    local count = 0
    for _, v in pairs(AdoptMeAPI.GetPlayersInventory().food) do
        if v.kind == "pet_age_potion" then
            count += 1
        end
    end
    return count
end

function AdoptMeAPI.GetFoodToGive(foodidGave)
    for id, food in pairs(AdoptMeAPI.GetPlayersInventory().food) do
        if food.id == foodidGave then
            return id
        end
    end
    return ""
end

function AdoptMeAPI.InventoryDB()
    return require(ReplicatedStorage.ClientDB.Inventory.InventoryDB)
end

--========================================================--
--                 AILMENTS
--========================================================--

function AdoptMeAPI.GetAilments(PetUnique1, PetUnique2, BabyUnique, Disabled)
    local Ailments = {
        FirstPet = {},
        SecondPet = {},
        Baby = {},
    }

    local Manager = AdoptMeAPI.GetAilmentsManager()
    local PetAilments = Manager.ailments
    local BabyAilments = Manager.baby_ailments

    if BabyUnique then
        for _, ail in pairs(BabyAilments) do
            if not Disabled or not table.find(Disabled, ail.kind) then
                Ailments.Baby[ail.kind] = {}
            end
        end
    end

    for id, list in pairs(PetAilments) do
        if id == PetUnique1 then
            for _, ail in pairs(list) do
                if not Disabled or not table.find(Disabled, ail.kind) then
                    Ailments.FirstPet[ail.kind] = {}
                end
            end
        elseif id == PetUnique2 then
            for _, ail in pairs(list) do
                if not Disabled or not table.find(Disabled, ail.kind) then
                    Ailments.SecondPet[ail.kind] = {}
                end
            end
        end
    end

    return Ailments
end

--========================================================--
--                 TEAM SWITCHING
--========================================================--

function AdoptMeAPI.SetPlayerToParent()
    AdoptMeAPI.RunRouterClient(false, "TeamAPI/ChooseTeam", {
        "Parents",
        { dont_respawn = true, source_for_logging = "avatar_editor" }
    })
end

function AdoptMeAPI.SetPlayerToBaby()
    AdoptMeAPI.RunRouterClient(false, "TeamAPI/ChooseTeam", {
        "Babies",
        { dont_respawn = true, source_for_logging = "avatar_editor" }
    })
end

--========================================================--
--                 EXPORT
--========================================================--

return AdoptMeAPI
