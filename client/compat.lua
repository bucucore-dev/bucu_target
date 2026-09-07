-- ============================================================================
-- BUCU Core — Target Compatibility Layer
-- Seamless Drop-in Support for ox_target and qb-target APIs
-- ============================================================================

-- ─── ox_target Compatibility Exports ─────────────────────────────────────────

local function NormalizeOptions(options)
    local normalized = {}
    if not options then return normalized end

    for idx, opt in ipairs(options) do
        table.insert(normalized, {
            name = opt.name or ('ox_opt_' .. idx),
            icon = opt.icon or 'hand',
            label = opt.label or 'Interaksi',
            distance = opt.distance or 2.5,
            job = opt.groups, -- ox_target uses 'groups' for jobs
            item = opt.items,
            canInteract = opt.canInteract,
            action = opt.onSelect,
            event = opt.event,
            serverEvent = opt.serverEvent
        })
    end
    return normalized
end

function addBoxZone(data)
    if not data or not data.coords then return end
    local zoneName = data.name or ('box_' .. tostring(GetGameTimer()))
    local radius = (data.size and (data.size.x + data.size.y) / 4) or 2.0
    AddTargetZone(zoneName, data.coords, radius, NormalizeOptions(data.options))
    return zoneName
end
exports('addBoxZone', addBoxZone)

function addSphereZone(data)
    if not data or not data.coords then return end
    local zoneName = data.name or ('sphere_' .. tostring(GetGameTimer()))
    AddTargetZone(zoneName, data.coords, data.radius or 2.0, NormalizeOptions(data.options))
    return zoneName
end
exports('addSphereZone', addSphereZone)

function addModel(models, options)
    AddTargetModel(models, NormalizeOptions(options))
end
exports('addModel', addModel)

function addEntity(entities, options)
    if type(entities) ~= 'table' then entities = { entities } end
    for _, ent in ipairs(entities) do
        AddTargetEntity(ent, NormalizeOptions(options))
    end
end
exports('addEntity', addEntity)

function removeZone(id)
    RemoveZone(id)
end
exports('removeZone', removeZone)

-- ─── qb-target Compatibility Exports ─────────────────────────────────────────

local function NormalizeQBOpt(data)
    local normalized = {}
    local optionsList = data and data.options or {}

    for idx, opt in ipairs(optionsList) do
        table.insert(normalized, {
            name = opt.name or ('qb_opt_' .. idx),
            icon = opt.icon or 'hand',
            label = opt.label or 'Interaksi',
            distance = data.distance or opt.distance or 2.5,
            job = opt.job,
            item = opt.item,
            canInteract = opt.canInteract,
            action = opt.action,
            event = opt.event,
            serverEvent = opt.serverEvent
        })
    end
    return normalized
end

function AddBoxZone(name, coords, length, width, data, customOptions)
    local options = (customOptions and customOptions.options) and NormalizeQBOpt(customOptions) or NormalizeQBOpt(data)
    local radius = ((length or 2.0) + (width or 2.0)) / 4
    AddTargetZone(name, coords, radius, options)
end
exports('AddBoxZone', AddBoxZone)

function AddSphereZone(name, coords, radius, data, customOptions)
    local options = (customOptions and customOptions.options) and NormalizeQBOpt(customOptions) or NormalizeQBOpt(data)
    AddTargetZone(name, coords, radius or 2.0, options)
end
exports('AddSphereZone', AddSphereZone)
