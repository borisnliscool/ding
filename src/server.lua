---@type { seed: number, nonce?: number }[]
local nonces = {}

---Generate and set a seed for the given client
---@param client? number
local function setSeedForClient(client)
    -- Use source if available otherwise use the given client
    -- Used so we can pass this function into the playerJoining event
    local target = source or client --[[@as integer]]

    -- Set the seed to the current time
    local seed = os.time()

    nonces[target] = { seed = seed }
    return TriggerClientEvent("ding:init", target, seed)
end

-- Give the client a seed when they join.
RegisterNetEvent("ding", setSeedForClient)

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

-- Handle player leaving
AddEventHandler("playerDropped", function()
    nonces[source] = nil
end)

-- Generate a new nonce based on the seed and previous nonce.
local function getNextNonce(source)
    local data = nonces[source]
    math.randomseed(data.seed + (data.nonce or 0))
    local newData = {
        seed = data.seed,
        nonce = math.random(1, 1000000)
    }
    nonces[source] = newData
    return newData
end

exports("getNextNonce", getNextNonce)
