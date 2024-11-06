fx_version 'cerulean'
game 'gta5'

author 'Ronin Development'
description 'Blip & Marker Management System for QBCore'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'

dependencies {
    'qb-core',
    'oxmysql',
    'qb-input'
}