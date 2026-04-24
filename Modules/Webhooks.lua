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
    local inv   = API.GetPlayersInventory()
    local money = API.GetPlayerMoney()

    return {
        username = "ASTRAL Hub",
        content = string.format(
            "Balance: %d\nPets: %d\nItems: %d",
            money or 0,
            inv.pets  and #inv.pets  or 0,
            inv.items and #inv.items or 0
        ),
    }
end

local function StartLoop(API)
    running = true
    Log("Webhook loop started")

    while running do
        task.wait(Interval)

        if not WebhookURL or WebhookURL == "" then
            Log("No webhook URL set")
            continue
        end

        local payload = BuildStatusPayload(API)
        SendPayload(WebhookURL, payload)
    end

    Log("Webhook loop stopped")
end

function Webhooks.Init(Tabs, Core, UI)
    local API = Core.AdoptMeAPI

    -- Use Misc tab (your Tabs.lua defines it)
    local tab = Tabs.Misc

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
        CurrentValue = Interval,
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

            SendPayload(WebhookURL, {
                username = "ASTRAL Hub",
                content  = "Test webhook from ASTRAL.",
            })
        end,
    })
end

return Webhooks
