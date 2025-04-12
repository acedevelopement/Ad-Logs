local function sendToDiscord(title, description, color)
    if Config.Webhook == "" then return end

    local embedData = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["footer"] = { ["text"] = "FiveM Logs | Ace Development" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, "POST", json.encode({
        username = "Server Logs",
        embeds = embedData
    }), { ["Content-Type"] = "application/json" })
end

local function getPlayerIdentifiers(playerId)
    local identifiers = { steam = "N/A", license = "N/A", discord = "N/A", ip = "N/A" }

    for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.find(id, "steam:") then
            identifiers.steam = id
        elseif string.find(id, "license:") then
            identifiers.license = id
        elseif string.find(id, "discord:") then
            identifiers.discord = "<@" .. string.sub(id, 9) .. ">"
        elseif string.find(id, "ip:") then
            identifiers.ip = string.sub(id, 4)
        end
    end

    return identifiers
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local playerId = source
    local identifiers = getPlayerIdentifiers(playerId)

    if Config.LogJoins then
        local message = Config.JoinMessage:gsub("{playerName}", name)
                                         :gsub("{playerID}", playerId) ..
                                         "\n**IP:** " .. identifiers.ip ..
                                         "\n**Steam:** " .. identifiers.steam ..
                                         "\n**License:** " .. identifiers.license ..
                                         "\n**Discord:** " .. identifiers.discord

        sendToDiscord("Player Joined", message, 3066993)
    end
end)

AddEventHandler("playerDropped", function(reason)
    local playerId = source
    local playerName = GetPlayerName(playerId) or "Unknown"
    local identifiers = getPlayerIdentifiers(playerId)

    if Config.LogLeaves then
        local message = Config.LeaveMessage:gsub("{playerName}", playerName)
                                          :gsub("{playerID}", playerId) ..
                                          "\n**IP:** " .. identifiers.ip ..
                                          "\n**Steam:** " .. identifiers.steam ..
                                          "\n**License:** " .. identifiers.license ..
                                          "\n**Discord:** " .. identifiers.discord

        sendToDiscord("Player Left", message, 15158332)
    end
end)

RegisterServerEvent("ad-logs:playerDied")
AddEventHandler("ad-logs:playerDied", function(killerId, victimId, weapon)
    if not Config.LogKills then return end

    local killerName = GetPlayerName(killerId) or "Unknown"
    local victimName = GetPlayerName(victimId) or "Unknown"
    local killerIdentifiers = getPlayerIdentifiers(killerId)
    local victimIdentifiers = getPlayerIdentifiers(victimId)

    local message = Config.KillMessage:gsub("{killerName}", killerName)
                                     :gsub("{killerID}", killerId)
                                     :gsub("{victimName}", victimName)
                                     :gsub("{victimID}", victimId)
                                     :gsub("{weapon}", weapon or "Unknown Weapon") ..
                                     "\n\n**Killer Details:**" ..
                                     "\n🔹 **IP:** " .. killerIdentifiers.ip ..
                                     "\n🔹 **Steam:** " .. killerIdentifiers.steam ..
                                     "\n🔹 **License:** " .. killerIdentifiers.license ..
                                     "\n🔹 **Discord:** " .. killerIdentifiers.discord ..
                                     "\n\n**Victim Details:**" ..
                                     "\n🔹 **IP:** " .. victimIdentifiers.ip ..
                                     "\n🔹 **Steam:** " .. victimIdentifiers.steam ..
                                     "\n🔹 **License:** " .. victimIdentifiers.license ..
                                     "\n🔹 **Discord:** " .. victimIdentifiers.discord

    sendToDiscord("Player Killed", message, 15105570)
end)
