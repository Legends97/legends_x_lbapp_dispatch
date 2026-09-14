RegisterNUICallback('app:ready', function(data, cb)
    local playerData = GetPlayerData()
    local job = playerData and playerData.job and playerData.job.name
    local isDispatchJob = false

    for _, configuredJob in pairs(Config.Jobs) do
        if configuredJob == job then
            isDispatchJob = true
            break
        end
    end

    if isDispatchJob then
        TriggerServerEvent('mfp_lb-dispatches:app:requestOpen', job)
    end

    cb({ isDispatchJob = isDispatchJob })
end)

RegisterNUICallback('app:accept', function(data, cb)
    local playerData = GetPlayerData()
    local job = playerData and playerData.job and playerData.job.name

    TriggerServerEvent('mfp_lb-dispatches:app:accept', data.id, job)
    cb('ok')
end)

RegisterNUICallback('app:decline', function(data, cb)
    ActiveDispatches[data.id] = nil
    cb('ok')
end)
