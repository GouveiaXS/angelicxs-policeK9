fx_version 'cerulean'
game 'gta5'

author 'AngelicXS'
version '1.2.2'

client_script 'client.lua'

server_script {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
    }

shared_script 'config.lua'
