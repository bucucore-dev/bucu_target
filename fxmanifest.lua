fx_version 'cerulean'
game 'gta5'
lua54 'yes'
transparentBackground 'yes'

name 'bucu_target'
description 'BUCU Core Next-Gen Eye Raycasting Target Interaction System'
author 'BUCU Framework Team'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

shared_scripts {
    '@bucu_shared/shared/constants.lua',
    '@bucu_shared/shared/config.lua',
    'config.lua',
    'locales/en.lua',
    'locales/id.lua'
}

client_scripts {
    'client/main.lua',
    'client/compat.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'bucu_shared'
}

exports {
    -- Native Bucu Target API
    'AddTargetZone',
    'AddTargetModel',
    'AddTargetEntity',
    'AddGlobalPed',
    'AddGlobalVehicle',
    'AddGlobalObject',
    'AddGlobalPlayer',
    'RemoveZone',
    'RemoveTargetModel',
    'RemoveTargetEntity',
    'IsTargetActive',

    -- ox_target Compatibility Exports
    'addBoxZone',
    'addSphereZone',
    'addModel',
    'addEntity',
    'removeZone',

    -- qb-target Compatibility Exports
    'AddBoxZone',
    'AddSphereZone',
    'AddTargetModel',
    'AddTargetEntity'
}
