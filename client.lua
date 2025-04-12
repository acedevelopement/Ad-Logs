RegisterNetEvent("baseevents:onPlayerKilled")
AddEventHandler("baseevents:onPlayerKilled", function(killerId, deathData)
    local victimId = PlayerId()
    local weapon = deathData.weaponhash or "Unknown"
    TriggerServerEvent("ad-logs:playerDied", killerId, victimId, weapon)
end)
