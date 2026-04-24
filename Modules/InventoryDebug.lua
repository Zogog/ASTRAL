--========================================================--
--                 ASTRAL.Modules.InventoryDebug
--========================================================--

local Debugger = {}

function Debugger.Init(Core)
    local API = Core.AdoptMeAPI

    print("\n================= ASTRAL DEBUG =================")

    -- Bucks
    local bucks = API.GetBucks and API.GetBucks() or nil
    print("[DEBUG] Bucks:", bucks)

    -- Currencies
    local currencies = API.GetCurrencies and API.GetCurrencies() or nil
    print("[DEBUG] Currencies:", currencies)

    -- Full Inventory
    local inv = API.GetPlayersInventory and API.GetPlayersInventory() or nil
    print("[DEBUG] Full Inventory Table:", inv)

    if inv then
        print("[DEBUG] Pets:", inv.pets)
        print("[DEBUG] Potions:", inv.potions)
        print("[DEBUG] Eggs:", inv.eggs)
        print("[DEBUG] Toys:", inv.toys)
        print("[DEBUG] Vehicles:", inv.vehicles)
        print("[DEBUG] Food:", inv.food)
    end

    -- Equipped Pets
    local equipped = API.GetEquippedPets and API.GetEquippedPets() or nil
    print("[DEBUG] Equipped Pets:", equipped)

    print("================================================\n")
end

return Debugger
