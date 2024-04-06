fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

author 'fabzhii'
description 'F-Cannabis by fabzhii'
version '1.0.0'

escrow_ignore {
    'config.lua'
}

client_scripts {
    "config.lua",
    "client.lua",
}

server_scripts {
    "config.lua",
    "@mysql-async/lib/MySQL.lua",
    "server.lua" ,
}
