if Config.Framework ~= "custom" then
    return
end

function Notify(text, errType)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(true, true)
end

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(500)
    end

    Loaded = true
end)

function GetPlayerData()
    local player = PlayerPedId()
    local playerData = nil -- add your own

    -- playerData.job have to be job-table with Label, name and more
    -- playerData.job.name have to be job-name

    return playerData
end