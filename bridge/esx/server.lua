if Config.Framework ~= "esx" then
    return
end

local ESX = exports.es_extended:getSharedObject()

function GetPlayerJob(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer and xPlayer.job and xPlayer.job.name
end
