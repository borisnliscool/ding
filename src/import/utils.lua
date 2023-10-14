return {
    ---Generate a new event name, as these can only be triggered by ding
    formatEventName = function(eventName)
        return ("dinged/%s"):format(eventName)
    end,
    getConfig = function()
        return {
            exports = json.decode(GetConvar('ding:invalidNonceExports', '[]')),
            warnUnused = GetConvar("ding:warnUnused", "false") == "true",
            whitelistedEvents = json.decode(GetConvar("ding:whitelistedEvents", "[]"))
        }
    end,
    -- https://stackoverflow.com/a/1579673
    split = function(pString, pPattern)
        local Table = {}
        local fpat = "(.-)" .. pPattern
        local last_end = 1
        local s, e, cap = pString:find(fpat, 1)
        while s do
            if s ~= 1 or cap ~= "" then
                table.insert(Table, cap)
            end
            last_end = e + 1
            s, e, cap = pString:find(fpat, last_end)
        end
        if last_end <= #pString then
            cap = pString:sub(last_end)
            table.insert(Table, cap)
        end
        return Table
    end,
    contains = function(tab, value)
        for _, v in pairs(tab) do
            if v == value then
                return true
            end
        end
        return false
    end
}
