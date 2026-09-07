-- ============================================================================
-- BUCU Core — Target Interaction Client Engine
-- Zero-overhead raycasting, zone detection, and Obsidian Glassmorphism NUI
-- ============================================================================

local isTargeting = false
local currentHitEntity = 0
local currentHitCoords = vector3(0, 0, 0)
local currentActiveOptions = {}

-- Registries
local Zones = {}
local Models = {}
local Entities = {}
local GlobalPeds = {}
local GlobalVehicles = {}
local GlobalObjects = {}
local GlobalPlayers = {}

-- Check if player has required job & grade
local function CheckJobRequirement(requiredJob, minGrade)
    if not requiredJob then return true end
    if exports and exports['bucu_core'] and exports['bucu_core'].GetJob then
        local j = exports['bucu_core']:GetJob(GetPlayerServerId(PlayerId()))
        if j and j.name == requiredJob then
            if not minGrade or (tonumber(j.grade) or 0) >= minGrade then
                return true
            end
        end
        return false
    end
    return true
end

-- Check if player has required item
local function CheckItemRequirement(requiredItem)
    if not requiredItem then return true end
    if exports and exports['bucu_inventory'] and exports['bucu_inventory'].HasItem then
        local has = exports['bucu_inventory']:HasItem(requiredItem, 1)
        return has == true
    end
    return true
end

-- Raycasting helper
local function RaycastCamera(distance)
    local camRot = GetGameplayCamRot(2)
    local camCoord = GetGameplayCamCoord()
    local pitch = math.rad(camRot.x)
    local yaw = math.rad(camRot.z)

    local direction = vector3(
        -math.sin(yaw) * math.cos(pitch),
        math.cos(yaw) * math.cos(pitch),
        math.sin(pitch)
    )

    local targetCoord = camCoord + direction * (distance or TargetConfig.MaxDistance or 6.5)
    local ray = StartShapeTestLosProbe(camCoord.x, camCoord.y, camCoord.z, targetCoord.x, targetCoord.y, targetCoord.z, -1, PlayerPedId(), 4)
    local _, hit, hitCoords, _, entityHit = GetShapeTestResult(ray)

    return hit == 1, hitCoords, entityHit
end

-- Filter valid options for target
local function FilterOptions(optionsList, entity, distance, coords)
    local valid = {}
    if not optionsList then return valid end

    for idx, opt in ipairs(optionsList) do
        local maxDist = opt.distance or TargetConfig.MaxDistance or 6.5
        if distance <= maxDist then
            local jobPass = CheckJobRequirement(opt.job, opt.minGrade)
            local itemPass = CheckItemRequirement(opt.item)
            local predicatePass = true

            if opt.canInteract and type(opt.canInteract) == 'function' then
                local ok, res = pcall(opt.canInteract, entity, distance, coords, opt.name)
                predicatePass = ok and (res == true)
            end

            if jobPass and itemPass and predicatePass then
                table.insert(valid, {
                    id = idx,
                    name = opt.name or ('option_' .. idx),
                    icon = opt.icon or 'hand',
                    label = opt.label or 'Interaksi',
                    badge = opt.badge,
                    event = opt.event,
                    serverEvent = opt.serverEvent,
                    command = opt.command,
                    action = opt.action
                })
            end
        end
    end
    return valid
end

-- Toggle targeting state
local function SetTargetingState(state)
    if isTargeting == state then return end
    isTargeting = state

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(isTargeting)

    SendNUIMessage({
        action = isTargeting and 'openTarget' or 'closeTarget'
    })

    if not isTargeting then
        currentHitEntity = 0
        currentActiveOptions = {}
    end
end

function IsTargetActive()
    return isTargeting
end
exports('IsTargetActive', IsTargetActive)

-- Main Raycast Thread (0ms when aiming, 250ms when idle)
CreateThread(function()
    while true do
        local sleep = 250

        if isTargeting then
            sleep = 0
            DisablePlayerFiring(PlayerPedId(), true)
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 140, true) -- Melee
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)

            local hit, hitCoords, entity = RaycastCamera(TargetConfig.MaxDistance)
            currentHitCoords = hitCoords
            currentHitEntity = entity

            local matchedOptions = {}
            local myPos = GetEntityCoords(PlayerPedId())
            local dist = #(myPos - hitCoords)

            -- 1. Check Zones
            for zoneName, zone in pairs(Zones) do
                local zoneDist = #(myPos - zone.coords)
                if zoneDist <= (zone.radius or 2.5) then
                    local filtered = FilterOptions(zone.options, 0, zoneDist, zone.coords)
                    for _, opt in ipairs(filtered) do
                        table.insert(matchedOptions, opt)
                    end
                end
            end

            -- 2. Check Entity Hit
            if hit and entity and entity ~= 0 and DoesEntityExist(entity) then
                local entityType = GetEntityType(entity)
                local model = GetEntityModel(entity)
                local entityDist = #(myPos - GetEntityCoords(entity))

                -- Check Model
                if Models[model] then
                    local filtered = FilterOptions(Models[model], entity, entityDist, hitCoords)
                    for _, opt in ipairs(filtered) do table.insert(matchedOptions, opt) end
                end

                -- Check Specific Entity
                if Entities[entity] then
                    local filtered = FilterOptions(Entities[entity], entity, entityDist, hitCoords)
                    for _, opt in ipairs(filtered) do table.insert(matchedOptions, opt) end
                end

                -- Check Global Peds
                if entityType == 1 and entity ~= PlayerPedId() then
                    local isPlayer = IsPedAPlayer(entity)
                    if isPlayer and #GlobalPlayers > 0 then
                        local filtered = FilterOptions(GlobalPlayers, entity, entityDist, hitCoords)
                        for _, opt in ipairs(filtered) do table.insert(matchedOptions, opt) end
                    elseif #GlobalPeds > 0 then
                        local filtered = FilterOptions(GlobalPeds, entity, entityDist, hitCoords)
                        for _, opt in ipairs(filtered) do table.insert(matchedOptions, opt) end
                    end
                end

                -- Check Global Vehicles
                if entityType == 2 and #GlobalVehicles > 0 then
                    local filtered = FilterOptions(GlobalVehicles, entity, entityDist, hitCoords)
                    for _, opt in ipairs(filtered) do table.insert(matchedOptions, opt) end
                end

                -- Check Global Objects
                if entityType == 3 and #GlobalObjects > 0 then
                    local filtered = FilterOptions(GlobalObjects, entity, entityDist, hitCoords)
                    for _, opt in ipairs(filtered) do table.insert(matchedOptions, opt) end
                end
            end

            -- Send updates to NUI
            currentActiveOptions = matchedOptions
            SendNUIMessage({
                action = 'updateTarget',
                hasTarget = (#matchedOptions > 0),
                options = matchedOptions
            })

            -- Enable mouse cursor or number shortcuts
            if #matchedOptions > 0 then
                -- Right click unlocks cursor to click options directly
                if IsControlJustReleased(0, 25) then -- Right Mouse
                    SetNuiFocus(true, true)
                end

                -- Number keys 1-5 shortcuts
                if TargetConfig.EnableNumberShortcuts then
                    for numKey = 1, math.min(#matchedOptions, 5) do
                        if IsControlJustReleased(0, 156 + numKey) or IsDisabledControlJustReleased(0, 156 + numKey) then
                            TriggerTargetOption(matchedOptions[numKey])
                            SetTargetingState(false)
                            break
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Execute selected option
function TriggerTargetOption(opt)
    if not opt then return end

    if opt.action and type(opt.action) == 'function' then
        opt.action(currentHitEntity, currentHitCoords)
    elseif opt.event then
        TriggerEvent(opt.event, {
            entity = currentHitEntity,
            coords = currentHitCoords,
            name = opt.name
        })
    elseif opt.serverEvent then
        TriggerServerEvent(opt.serverEvent, {
            entity = currentHitEntity,
            coords = currentHitCoords,
            name = opt.name
        })
    elseif opt.command then
        ExecuteCommand(opt.command)
    end
end

-- NUI Callbacks
RegisterNUICallback('selectOption', function(data, cb)
    SetNuiFocus(false, false)
    SetTargetingState(false)

    local optId = tonumber(data.id)
    if optId and currentActiveOptions[optId] then
        TriggerTargetOption(currentActiveOptions[optId])
    end
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SetTargetingState(false)
    cb('ok')
end)

-- Keymapping for Left Alt
RegisterKeyMapping('+target', 'Aktifkan Mode Interaksi Target (Mata)', 'keyboard', 'LMENU')

RegisterCommand('+target', function()
    SetTargetingState(true)
end, false)

RegisterCommand('-target', function()
    if not TargetConfig.ToggleMode then
        SetTargetingState(false)
    end
end, false)

-- Native Bucu Exports
function AddTargetZone(name, coords, radius, options)
    if not name or not coords then return end
    Zones[name] = {
        name = name,
        coords = coords,
        radius = radius or 2.0,
        options = options or {}
    }
end
exports('AddTargetZone', AddTargetZone)

function AddTargetModel(models, options)
    if type(models) ~= 'table' then models = { models } end
    for _, m in ipairs(models) do
        local hash = (type(m) == 'string') and GetHashKey(m) or m
        Models[hash] = options
    end
end
exports('AddTargetModel', AddTargetModel)

function AddTargetEntity(entity, options)
    if not entity or entity == 0 then return end
    Entities[entity] = options
end
exports('AddTargetEntity', AddTargetEntity)

function AddGlobalPed(options)
    for _, opt in ipairs(options) do table.insert(GlobalPeds, opt) end
end
exports('AddGlobalPed', AddGlobalPed)

function AddGlobalVehicle(options)
    for _, opt in ipairs(options) do table.insert(GlobalVehicles, opt) end
end
exports('AddGlobalVehicle', AddGlobalVehicle)

function AddGlobalObject(options)
    for _, opt in ipairs(options) do table.insert(GlobalObjects, opt) end
end
exports('AddGlobalObject', AddGlobalObject)

function AddGlobalPlayer(options)
    for _, opt in ipairs(options) do table.insert(GlobalPlayers, opt) end
end
exports('AddGlobalPlayer', AddGlobalPlayer)

function RemoveZone(name)
    Zones[name] = nil
end
exports('RemoveZone', RemoveZone)

function RemoveTargetModel(models)
    if type(models) ~= 'table' then models = { models } end
    for _, m in ipairs(models) do
        local hash = (type(m) == 'string') and GetHashKey(m) or m
        Models[hash] = nil
    end
end
exports('RemoveTargetModel', RemoveTargetModel)

function RemoveTargetEntity(entity)
    Entities[entity] = nil
end
exports('RemoveTargetEntity', RemoveTargetEntity)
