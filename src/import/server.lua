local _RegisterNetEvent = RegisterNetEvent
local _AddEventHandler = AddEventHandler
local _TriggerEvent = TriggerEvent
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

-- Default events we dont want to interrupt
local defaultEvents = {
    "entityCreated",
    "entityCreating",
    "entityRemoved",
    "onResourceListRefresh",
    "onResourceStart",
    "onResourceStarting",
    "onResourceStop",
    "onServerResourceStart",
    "onServerResourceStop",
    "playerConnecting",
    "playerEnteredScope",
    "playerJoining",
    "playerLeftScope",
    "ptFxEvent",
    "removeAllWeaponsEvent",
    "startProjectileEvent",
    "weaponDamageEvent",
    "CEventName",
    "entityDamaged",
    "gameEventTriggered",
    "mumbleConnected",
    "mumbleDisconnected",
    "onClientResourceStart",
    "onClientResourceStop",
    "populationPedCreating",
    "playerDropped",
    "rconCommand",
}

local isInternalEvent = function(e)
    return Utils.contains(defaultEvents, e) or e:find("^__cfx_export_.*")
end

--Overwrite the default AddEventHandler to use nonces instead
AddEventHandler = function(eventName, callback)
    -- If it's an internal event or if it's whitelisted, run native behavior
    if isInternalEvent(eventName) or Utils.contains(Utils.getConfig().whitelistedEvents, eventName) then
        return _AddEventHandler(eventName, callback)
    end

    -- Add an event handler to handle the events where scripts are not using ding.
    _AddEventHandler(eventName, function()
        if source == "" then
            if Utils.getConfig().warnUnused then
                local invoker = GetInvokingResource()

                error(
                    ("event '%s' triggered by '%s' was not handled by '%s' because '%s' is using Ding and '%s' is not.")
                    :format(eventName, invoker, RESOURCE, RESOURCE, invoker)
                )
            end
            return
        end

        error(
            ("client '%s' tried to trigger event '%s' which is protected by ding, without using ding."):format(
                source,
                eventName
            )
        )
    end)

    -- The actual event handler that handles nonces.
    return _AddEventHandler(Utils.formatEventName(eventName), function(clientNonce, ...)
        local isClient = type(source) == "number" and source > 0

        -- If the source is not a client it must be the server
        -- and we can trust the server so we can just run the callback
        if not isClient then
            return callback(...)
        end

        local nonceData = ding:getNextNonce(source)

        if not nonceData then
            -- We dont have nonce data for this client.
            return error(("Nonce not found for event '%s'"):format(eventName))
        end

        if nonceData.nonce ~= clientNonce then
            -- The client provided an invalid nonce, or no nonce at all.

            -- Loop over all exports in the config
            for _, exportData in pairs(Utils.getConfig().exports) do
                local data = Utils.split(exportData, ":")
                local resource, export = data[1], data[2]

                local success, err = pcall(function()
                    -- Trigger the export
                    return exports[resource][export](nil, {
                        source = source,
                        event = eventName,
                        clientNonce = clientNonce,
                        invoker = GetInvokingResource()
                    })
                end)

                if not success and err then
                    error(err)
                end
            end

            return
        end

        return callback(...)
    end)
end

-- Overwrite the default RegisterNetEvent
RegisterNetEvent = function(eventName, callback)
    _RegisterNetEvent(eventName)
    local netEvent = _RegisterNetEvent(Utils.formatEventName(eventName))
    return callback and AddEventHandler(eventName, callback) or netEvent
end

-- Overwrite the default TriggerEvent
TriggerEvent = function(eventName, ...)
    if isInternalEvent(eventName) then
        return _TriggerEvent(eventName, table.unpack({ ... }))
    end

    return _TriggerEvent(Utils.formatEventName(eventName), nil, table.unpack({ ... }))
end

return true
