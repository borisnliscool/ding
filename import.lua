local VERSION = IsDuplicityVersion() and "server" or "client"
local RESOURCE = GetCurrentResourceName()

local file = ("src/import/%s.lua"):format(VERSION)
local datafile = LoadResourceFile("ding", file)
local func, err = load(datafile, ('@ding/%s'):format(file))

if not func or err then
    error(err)
end

if not func() then
    error(("Failed to load 'ding' for %s"):format(RESOURCE))
end
