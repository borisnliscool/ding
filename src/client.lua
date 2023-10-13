CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(10)
    end

    TriggerServerEvent("ding")
end)
