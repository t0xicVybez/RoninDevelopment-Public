fx_version 'cerulean'
game 'gta5'

author 'Ronin Development'
description 'RD-Wellness - A comprehensive wellness Center & Job for QBCore'
version '0.1a'

shared_scripts {
    '@ab-core/shared/locale.lua'
    'locales/en.lua' -- Need to add locales for other languages
    'config.lua'
}

client_scripts {
    client/main.lua
}

server_scripts {
    'server/mains.lua'
}

lua54 'yes'