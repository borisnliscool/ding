local _RegisterNetEvent = RegisterNetEvent
local _AddEventHandler = AddEventHandler
local _TriggerEvent = TriggerEvent
local RESOURCE = GetCurrentResourceName()

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

---@type { seed: number, nonce?: number }[]
local nonces = {}

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

---Generate and set a seed for the given client
---@param client? number
local function setSeedForClient(client)
    -- Use source if available otherwise use the given client
    -- Used so we can pass this function into the playerJoining event
    local target = source or client --[[@as integer]]

    -- Set the seed to the current time
    local seed = os.time()

    nonces[target] = { seed = seed }
    return TriggerClientEvent(("ding:%s:init"):format(RESOURCE), target, seed)
end

-- Give the client a seed when they join.
_RegisterNetEvent("ding", setSeedForClient)

-- Handle player leaving
_AddEventHandler("playerDropped", function()
    nonces[source] = nil
end)

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

        if not nonces[source] then
            -- We dont have nonce data for this client.
            return error(("Nonce not found for event '%s'"):format(eventName))
        end

        nonces[source] = Utils.getNextNonce(nonces[source])

        if nonces[source].nonce ~= clientNonce then
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
                        clientNonce = clientNonce
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

-- Loop over all players and give them a seed.
-- Only used in development when scripts are restarted
CreateThread(function()
    Wait(100)
    for i = 1, 10000 do -- Looping over all players could be done better
        if GetPlayerPed(i) ~= 0 then
            setSeedForClient(i)
        end
    end
end)

return true
