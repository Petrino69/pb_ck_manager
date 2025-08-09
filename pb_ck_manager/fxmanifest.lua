fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Petrino + CHATGPT'
description 'CK Manager pro ESX s ox_lib UI: online/offline CK, tvrdé smazání postavy a všech vozidel, logy na CK webhook.'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

dependencies {
    'oxmysql',
    'ox_lib'
}
