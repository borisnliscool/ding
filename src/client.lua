CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(10)
    end

    TriggerServerEvent("ding")
end)

local ready = false
local nonceData = {}

RegisterNetEvent("ding:init", function(seed)
    math.randomseed(seed)
    nonceData = { seed = seed }
    ready = true
end)

local function dingReady()
    return ready
end

-- Generate a new nonce based on the seed and previous nonce.
local function getNextNonce()
    math.randomseed(nonceData.seed + (nonceData.nonce or 0))
    nonceData = {
        seed = nonceData.seed,
        nonce = math.random(1, 1000000)
    }
    return nonceData
end

exports("isReady", dingReady)
exports("getNextNonce", getNextNonce)
