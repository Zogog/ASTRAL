--========================================================--
--                 ASTRAL.Modules.TeleportHub
--========================================================--

local TeleportHub = {}

function TeleportHub.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI
    local Teleport = Core.Teleport

    local tab = Tabs.Teleports or Tabs.Utility or Tabs.Main

    tab:CreateSection("Teleport Hub")

    local routes = {
        "Home",
        "MainMap",
        "Neighborhood",
        "Nursery",
        "School",
        "Hospital",
        "Salon",
        "PizzaShop",
        "BabyShop",
        "ToyShop",
        "SkyCastle",
    }

    tab:CreateDropdown({
        Name = "Quick Teleport",
        Options = routes,
        CurrentOption = "Home",
        Callback = function(choice)
            if Teleport.Exists(choice) then
                Teleport.Execute(API, choice)
            else
                warn("[ASTRAL TeleportHub] Unknown route:", choice)
            end
        end,
    })

    tab:CreateButton({
        Name = "Go Home",
        Callback = function()
            Teleport.GoHome(API)
        end,
    })

    tab:CreateButton({
        Name = "Go to Main Map",
        Callback = function()
            Teleport.GoMain(API)
        end,
    })

    tab:CreateButton({
        Name = "Go to Neighborhood",
        Callback = function()
            Teleport.GoNeighborhood(API)
        end,
    })
end

return TeleportHub
