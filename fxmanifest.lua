fx_version 'cerulean'
game 'gta5'

lua54 "yes"
use_experimental_fxv2_oal "yes"

name "MFP LB-Dispatches App"
author 'MFPSCRIPTS'
description 'LB Phone Dispatches App'
version '1.1.0'

files {
    "html/*.*",
    "locales/*.lua",
    "postals.json"
}

shared_script {
    "config/*.lua",
    "bridge/frameworks.lua",
    "translate.lua"
}

client_scripts {
    "bridge/**/client.lua",
    "client/*.lua"
}

server_scripts {
    "bridge/**/server.lua",
    "server/*.lua"
}

escrow_ignore {
    "bridge/**/*.lua",
    "locales/*.lua",
    "config/**/*.lua"
}