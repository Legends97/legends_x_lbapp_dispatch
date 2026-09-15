if Config.Framework ~= "qb-core" then
    return
end

local QBCore = exports["qb-core"]:GetCoreObject()

function GetPlayerJob(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player and Player.PlayerData.job.name
end
