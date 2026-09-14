if Config.Framework ~= "esx" then
    return
end

local export, ESX = pcall(function()
    return exports.es_extended:getSharedObject()
end)

if not export then
    while not ESX do
        TriggerEvent("esx:getSharedObject", function(obj)
            ESX = obj
        end)

        Wait(500)
    end
end

RegisterNetEvent("esx:playerLoaded", function(playerData)
    ESX.PlayerData = playerData
    ESX.PlayerLoaded = true
end)

function Notify(text, errType)
    ESX.ShowNotification(text, errType)
end

while not ESX.PlayerLoaded do
    Wait(500)
end

Loaded = true

-- client

function GetPlayerData()
    return ESX.PlayerData
end