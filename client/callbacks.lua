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
        TriggerServerEvent('mfp_lb-dispatches:app:requestOpen')
    end

    cb({
        isDispatchJob = isDispatchJob,
        appName = Config.AppName,
        i18n = {
            onDuty = Translation['on_duty'],
            noActiveDispatches = Translation['no_active_dispatches'],
            accept = Translation['accept'],
            decline = Translation['decline'],
            postal = Translation['postal'],
        },
    })
end)

RegisterNUICallback('app:accept', function(data, cb)
    TriggerServerEvent('mfp_lb-dispatches:app:accept', data.id)
    cb('ok')
end)

RegisterNUICallback('app:decline', function(data, cb)
    ActiveDispatches[data.id] = nil
    cb('ok')
end)
