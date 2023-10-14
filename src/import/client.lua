local _TriggerServerEvent = TriggerServerEvent
local RESOURCE = GetCurrentResourceName()
local ding = exports.ding

-- Function to import the utils
local function importUtils()
    local file = "src/import/utils.lua"
    local datafile = LoadResourceFile("ding", file)
    local func, err = load(datafile, ('@ding/%s'):format(file))

    if not func or err then
        error(err)
    end

    local data = func()
    if not data then
        error(("Failed to import utils for %s"):format(RESOURCE))
    end
    return data
end

local Utils = importUtils()

-- Overwrite the default TriggerServerEvent
function TriggerServerEvent(eventName, ...)
    return _TriggerServerEvent(
        Utils.formatEventName(eventName),
        ding:getNextNonce().nonce,
        table.unpack({ ... })
    )
end

return true
