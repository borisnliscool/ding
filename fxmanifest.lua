fx_version "cerulean"
game "gta5"

name "Ding"
description "Ding protects FiveM events from cheaters using random nonces to prevent replay attacks."
author "borisnliscool"
version "1.0.0"
repository "https://github.com/borisnliscool/ding"

server_script "src/server.lua"
client_script "src/client.lua"

files {
    "src/import/utils.lua",
    "src/import/client.lua",
    "import.lua"
}
