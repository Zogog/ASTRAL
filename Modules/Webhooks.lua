--========================================================--
--                 ASTRAL.Modules.Webhooks
--========================================================--

local HttpService = game:GetService("HttpService")

local Webhooks = {}

local running = false
local WebhookURL = nil
local Interval = 60

local function Log(msg)
    print("[ASTRAL Webhooks] " .. msg)
end

local function SendPayload(url, data)
    local json = HttpService:JSONEncode(data)

    local ok, err = pcall(function()
        HttpService:PostAsync(url, json, Enum.HttpContentType.ApplicationJson)
    end)

    if not ok then
        Log("Failed to send webhook: " .. tostring(err))
    end
end

local function BuildStatusPayload(API)
    local inv = API.GetPlayersInventory()
    local money = API.GetPlayerMoney()

    return {
        username = "ASTRAL Hub",
        content = string.format(
            "Balance: %d\nPets: %d\nItems: %d",
            money or 0,
            inv.pets and #inv.pets or 0,
            inv.items and #inv.items or 0
        ),
    }
end

local function StartLoop(API)
    running = true
    Log("Webhooks loop started")

    while running do
        task.wait(Interval)

        if not WebhookURL or WebhookURL == "" then
            Log("No webhook URL set")
            continue
        end

        local payload = BuildStatusPayload(API)
        SendPayload(WebhookURL, payload)
    end

    Log("Webhooks loop stopped")
end

function Webhooks.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI

    local tab = Tabs.Utility or Tabs.Main or Tabs.Autofarm

    tab:CreateSection("Webhooks")

    tab:CreateInput({
        Name = "Webhook URL",
        PlaceholderText = "Enter Discord webhook URL",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            WebhookURL = text
            Log("Webhook URL updated")
        end,
    })

    tab:CreateSlider({
        Name = "Interval (seconds)",
        Range = {10, 300},
        Increment = 10,
        CurrentValue = 60,
        Callback = function(value)
            Interval = value
            Log("Interval set to " .. value .. "s")
        end,
    })

    tab:CreateToggle({
        Name = "Enable Webhook Loop",
        CurrentValue = false,
        Callback = function(state)
            if state then
                if not running then
                    task.spawn(StartLoop, API)
                end
            else
                running = false
            end
        end,
    })

    tab:CreateButton({
        Name = "Send Test Webhook",
        Callback = function()
            if not WebhookURL or WebhookURL == "" then
                Log("No webhook URL set")
                return
            end

            local payload = {
                username = "ASTRAL Hub",
                content = "Test webhook from ASTRAL.",
            }

            SendPayload(WebhookURL, payload)
        end,
    })
end

return Webhooks
