return {
    -- Generate a new nonce based on the seed and previous nonce.
    getNextNonce = function(nonceData)
        math.randomseed(nonceData.seed + (nonceData.nonce or 0))
        return {
            seed = nonceData.seed,
            nonce = math.random(1, 1000000)
        }
    end,
    ---Generate a new event name, as these can only be triggered by ding
    formatEventName = function(eventName)
        return ("dinged/%s"):format(eventName)
    end
}
