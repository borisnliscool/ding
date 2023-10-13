local _TriggerServerEvent = TriggerServerEvent
local RESOURCE = GetCurrentResourceName()

local function importUtils()
    local file = "src/utils.lua"
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
local nonceData = {}

RegisterNetEvent(("ding:%s:init"):format(RESOURCE), function(seed)
    math.randomseed(seed)
    nonceData = { seed = seed }
end)

function TriggerServerEvent(eventName, ...)
    nonceData = Utils.getNextNonce(nonceData)
    _TriggerServerEvent(Utils.formatEventName(eventName), nonceData.nonce, ...)
end

return true
