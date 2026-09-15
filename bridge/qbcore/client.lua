if Config.Framework ~= "qb-core" then
    return
end

local QB = exports["qb-core"]:GetCoreObject()

function Notify(text, errType)
    QB.Functions.Notify(text, errType)
end

RegisterNetEvent("QBCore:Client:OnJobUpdate", function()
    if RefreshDispatchAppVisibility then RefreshDispatchAppVisibility() end
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end

    Loaded = true
end)

-- client

function GetPlayerData()
    local playerData = QB.Functions.GetPlayerData()

    return playerData
end