-- ============================================================================
-- BUCU Core — Target Interaction Server Controller
-- Networked zone registry & target event dispatcher
-- ============================================================================

local globalZones = {}

-- Register a server-wide target zone synced to newly connected players
RegisterNetEvent('bucu:target:server:registerZone', function(zoneName, zoneData)
    if not zoneName or not zoneData then return end
    globalZones[zoneName] = zoneData
    TriggerClientEvent('bucu:target:client:syncZone', -1, zoneName, zoneData)
end)

-- Fetch active server-wide zones
RegisterNetEvent('bucu:target:server:requestZones', function()
    local src = source
    TriggerClientEvent('bucu:target:client:syncAllZones', src, globalZones)
end)
