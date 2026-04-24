--========================================================--
--                 ASTRAL.Modules.Webhooks
--      Advanced v2 — Discord Notifications System
--========================================================--

local Webhooks = {}

--========================================================--
--                 INTERNAL STATE
--========================================================--

local webhookURL = nil
local username = "ASTRAL Hub"
local avatarURL = "https://i.imgur.com/0ZfQZpF.png" -- optional icon

local lastSent = 0
local rateLimit = 1 -- seconds between messages

--========================================================--
--                 LOGGING
--========================================================--

local function Log(msg)
    print("[ASTRAL Webhooks] " .. msg)
end

--========================================================--
--                 SEND RAW WEBHOOK
--========================================================--

local function SendRaw(payload)
    if not webhookURL or webhookURL == "" then
        return
    end

    -- Rate limit protection
    if tick() - lastSent < rateLimit then
        return
    end
    lastSent = tick()

    local json = game:GetService("HttpService"):JSONEncode(payload)

    local success, err = pcall(function()
        request({
            Url = webhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = json
        })
    end)

    if not success then
        warn("[ASTRAL Webhooks] Failed to send webhook:", err)
    end
end

--========================================================--
--                 PUBLIC SEND FUNCTIONS
--========================================================--

function Webhooks.SendMessage(text)
    if not webhookURL then return end

    SendRaw({
        username = username,
        avatar_url = avatarURL,
        content = text
    })
end

function Webhooks.SendEmbed(title, description, color)
    if not webhookURL then return end

    SendRaw({
        username = username,
        avatar_url = avatarURL,
        embeds = {{
            title = title,
            description = description,
            color = color or 0x00FFFF,
            timestamp = DateTime.now():ToIsoDate()
        }}
    })
end

--========================================================--
--                 PREBUILT EVENT HELPERS
--========================================================--

function Webhooks.PetFullyGrown(petName, petId)
    Webhooks.SendEmbed(
        "🎉 Pet Fully Grown!",
        string.format("**Pet:** %s\n**ID:** %s", petName, petId),
        0x00FF00
    )
end

function Webhooks.EggHatched(eggName, newPetName)
    Webhooks.SendEmbed(
        "🥚 Egg Hatched!",
        string.format("**Egg:** %s\n**New Pet:** %s", eggName, newPetName),
        0xFFD700
    )
end

function Webhooks.AilmentSolved(petName, ailment)
    Webhooks.SendEmbed(
        "✨ Ailment Solved",
        string.format("**Pet:** %s\n**Ailment:** %s", petName, ailment),
        0x87CEEB
    )
end

function Webhooks.BabyAilmentSolved(ailment)
    Webhooks.SendEmbed(
        "👶 Baby Ailment Solved",
        string.format("**Ailment:** %s", ailment),
        0xFF69B4
    )
end

function Webhooks.AutoNeedsEvent(text)
    Webhooks.SendEmbed("⚙️ AutoNeeds Event", text, 0xCCCCFF)
end

function Webhooks.AutoEggsEvent(text)
    Webhooks.SendEmbed("🥚 AutoEggs Event", text, 0xFFAA00)
end

function Webhooks.BabyFarmEvent(text)
    Webhooks.SendEmbed("👶 BabyFarm Event", text, 0xFF77AA)
end

--========================================================--
--                 UI INITIALIZATION
--========================================================--

function Webhooks.Init(Tabs)
    local tab = Tabs.Misc

    tab:CreateSection("Webhooks")

    -- Webhook URL input
    tab:CreateInput({
        Name = "Discord Webhook URL",
        PlaceholderText = "Paste your webhook URL here",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            webhookURL = text ~= "" and text or nil
            Log("Webhook URL updated")
        end,
    })

    -- Username
    tab:CreateInput({
        Name = "Webhook Username",
        PlaceholderText = "ASTRAL Hub",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            username = text ~= "" and text or "ASTRAL Hub"
        end,
    })

    -- Avatar URL
    tab:CreateInput({
        Name = "Webhook Avatar URL",
        PlaceholderText = "Optional image URL",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            avatarURL = text ~= "" and text or avatarURL
        end,
    })

    -- Test button
    tab:CreateButton({
        Name = "Send Test Webhook",
        Callback = function()
            Webhooks.SendEmbed("ASTRAL Webhook Test", "Webhook is working!")
        end,
    })
end

return Webhooks
